import copy
import importlib.util
import json
from pathlib import Path
import subprocess
import sys
import tempfile
import unittest


SCRIPT = Path(__file__).resolve().parents[1] / "skills/bulk-jobs/scripts/check-profile-results.py"
SPEC = importlib.util.spec_from_file_location("profile_results", SCRIPT)
CHECKER = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(CHECKER)


class ProfileResultsTest(unittest.TestCase):
    def setUp(self):
        self.manifest = {"job_id": "job-a", "product": "profile_search", "rows": [
            {"profile_url": f"/in/person-{i}", "source_id": f"record-{i}"} for i in range(353)
        ]}
        self.rows = [{"row_index": i, "status": "success",
                      "lm_input": {"profile_url": f"/in/person-{i}"},
                      "lm_output": {"profile_url": f"https://profiles.example/in/person-{i}/"}}
                     for i in range(353)]

    def join(self, rows=None, manifest=None):
        return CHECKER.checked_join(manifest or self.manifest, "job-a", [{"rows": rows if rows is not None else self.rows}])

    def test_353_rows_join_to_submission_even_when_results_are_shuffled(self):
        joined = self.join(list(reversed(self.rows)))
        self.assertTrue(joined["all_source_rows_present"])
        self.assertEqual(353, joined["checked_rows"])
        self.assertEqual("record-352", joined["rows"][352]["source"]["source_id"])

    def test_wrong_job_id_is_rejected(self):
        with self.assertRaisesRegex(ValueError, "job ID"):
            CHECKER.checked_join(self.manifest, "job-b", [{"rows": self.rows}])

    def test_same_indices_from_different_submission_are_rejected(self):
        manifest = copy.deepcopy(self.manifest)
        for i, row in enumerate(manifest["rows"]):
            row["profile_url"] = f"/in/unrelated-{i}"
        with self.assertRaisesRegex(ValueError, "Input identity mismatch"):
            self.join(manifest=manifest)

    def test_filtered_rows_keep_source_indices(self):
        joined = self.join([self.rows[352], self.rows[17]])
        self.assertFalse(joined["all_source_rows_present"])
        self.assertEqual(["record-17", "record-352"], [p["source"]["source_id"] for p in joined["rows"]])

    def test_invalid_indices_and_duplicate_pages_are_rejected(self):
        for index in [-1, 353, True, "0", None]:
            with self.subTest(index=index), self.assertRaises(ValueError):
                self.join([{**self.rows[0], "row_index": index}])
        with self.assertRaisesRegex(ValueError, "Duplicate"):
            CHECKER.checked_join(self.manifest, "job-a", [{"rows": self.rows}, {"rows": self.rows[:1]}])

    def test_missing_and_mismatched_identities_are_rejected(self):
        for field, value in [("lm_input", None), ("lm_input", {}), ("lm_output", {}),
                             ("lm_output", {"profile_url": "/in/someone-else"})]:
            with self.subTest(field=field, value=value), self.assertRaises(ValueError):
                self.join([{**self.rows[0], field: value}])

    def test_failed_rows_preserve_identity_without_inventing_output(self):
        joined = self.join([{**self.rows[17], "status": "failed", "lm_output": None}])
        self.assertIsNone(joined["rows"][0]["result"]["lm_output"])

    def test_cli_refuses_invalid_batch_before_creating_output_and_never_overwrites(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            (root / "manifest.json").write_text(json.dumps(self.manifest))
            bad_rows = copy.deepcopy(self.rows)
            bad_rows[-1]["lm_input"]["profile_url"] = "/in/wrong-person"
            (root / "page.json").write_text(json.dumps({"rows": bad_rows}))
            command = [sys.executable, str(SCRIPT), "--manifest", str(root / "manifest.json"),
                       "--job-id", "job-a", "--results", str(root / "page.json"), "--output", str(root / "out.json")]
            self.assertEqual(1, subprocess.run(command, capture_output=True).returncode)
            self.assertFalse((root / "out.json").exists())
            (root / "page.json").write_text(json.dumps({"rows": self.rows}))
            self.assertEqual(0, subprocess.run(command, capture_output=True).returncode)
            before = (root / "out.json").read_bytes()
            self.assertEqual(1, subprocess.run(command, capture_output=True).returncode)
            self.assertEqual(before, (root / "out.json").read_bytes())


if __name__ == "__main__":
    unittest.main()
