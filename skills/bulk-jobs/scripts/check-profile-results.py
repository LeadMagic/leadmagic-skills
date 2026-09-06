#!/usr/bin/env python3
"""Validate a profile job's identity joins before creating a new result file."""

import argparse
import json
import os
import sys
from urllib.parse import urlsplit


def profile_identity(value):
    if not isinstance(value, str) or not value.strip():
        raise ValueError("Missing profile identity")
    value = value.strip()
    path = urlsplit(value).path if "://" in value else value.split("?", 1)[0]
    parts = path.strip("/").split("/")
    if len(parts) != 2 or parts[0] != "in" or not parts[1]:
        raise ValueError("Unsupported profile identity; review before merging")
    return parts[1].casefold()


def checked_join(manifest, fetched_job_id, pages):
    if not isinstance(manifest, dict) or not fetched_job_id:
        raise ValueError("Missing job manifest or fetched job ID")
    if manifest.get("job_id") != fetched_job_id:
        raise ValueError("Fetched job ID does not match the submission manifest")
    if manifest.get("product") != "profile_search":
        raise ValueError("Checker supports single-product profile_search jobs only")
    source = manifest.get("rows")
    if not isinstance(source, list) or not source:
        raise ValueError("Manifest must contain the exact submitted rows")
    identities = [profile_identity(row.get("profile_url")) for row in source]
    seen = set()
    checked = []
    if not pages:
        raise ValueError("No result pages supplied")
    for page in pages:
        if not isinstance(page, dict) or not isinstance(page.get("rows"), list):
            raise ValueError("Expected unchanged /results response with a rows array")
        for result in page["rows"]:
            if not isinstance(result, dict):
                raise ValueError("Invalid result row")
            index = result.get("row_index")
            if type(index) is not int or not 0 <= index < len(source):
                raise ValueError("Result row_index is not a valid submission index")
            if index in seen:
                raise ValueError("Duplicate row_index; overlapping pages or ambiguous products")
            seen.add(index)
            lm_input = result.get("lm_input")
            if not isinstance(lm_input, dict):
                raise ValueError("Result has no input identity")
            if profile_identity(lm_input.get("profile_url")) != identities[index]:
                raise ValueError(f"Input identity mismatch at row_index {index}; merge stopped")
            output = result.get("lm_output")
            if isinstance(output, dict) and output.get("profile_url") is not None:
                if profile_identity(output["profile_url"]) != identities[index]:
                    raise ValueError(f"Output identity mismatch at row_index {index}; review required")
            elif result.get("status") == "success":
                raise ValueError(f"Successful result missing output identity at row_index {index}")
            checked.append({"source": source[index], "result": result})
    checked.sort(key=lambda pair: pair["result"]["row_index"])
    return {
        "job_id": fetched_job_id,
        "submitted_rows": len(source),
        "checked_rows": len(checked),
        "all_source_rows_present": len(checked) == len(source),
        "rows": checked,
    }


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--manifest", required=True)
    parser.add_argument("--job-id", required=True, help="Job ID captured from the fetch URL")
    parser.add_argument("--results", nargs="+", required=True)
    parser.add_argument("--output", required=True, help="New file; existing files are never overwritten")
    args = parser.parse_args()
    try:
        with open(args.manifest, encoding="utf-8") as handle:
            manifest = json.load(handle)
        pages = []
        for path in args.results:
            with open(path, encoding="utf-8") as handle:
                pages.append(json.load(handle))
        joined = checked_join(manifest, args.job_id, pages)
        # Serialize and validate everything before opening the output for creation.
        serialized = json.dumps(joined, ensure_ascii=False, indent=2) + "\n"
        with open(args.output, "x", encoding="utf-8", opener=lambda path, flags: os.open(path, flags, 0o600)) as handle:
            handle.write(serialized)
        print(f"Validated {joined['checked_rows']} of {joined['submitted_rows']} source rows")
    except (OSError, ValueError, TypeError, AttributeError):
        # Do not include paths or customer values from malformed input in console output.
        print("Join refused. Check job ID, indices, identities, input shapes, and output path. No source file was modified.", file=sys.stderr)
        return 1
    return 0


if __name__ == "__main__":
    sys.exit(main())
