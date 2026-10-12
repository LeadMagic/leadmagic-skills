"""Approval decisions for state-changing hosted MCP calls."""
import json
import os
from pathlib import Path
import subprocess
import unittest

HOOK = Path(__file__).resolve().parents[1] / "scripts" / "approval-policy.sh"


class ApprovalPolicyTest(unittest.TestCase):
    def decision(self, name, mode="default", token=None, prefix="mcp__plugin_leadmagic_leadmagic__"):
        tool_input = {}
        if token is not None:
            tool_input["confirmation_token"] = token
        payload = json.dumps({
            "permission_mode": mode,
            "tool_name": prefix + name,
            "tool_input": tool_input,
        })
        env = dict(os.environ, LEADMAGIC_ASK_ALL="0")
        output = subprocess.check_output(
            ["/bin/bash", str(HOOK)], input=payload, text=True, env=env
        )
        return json.loads(output)["hookSpecificOutput"]["permissionDecision"]

    def test_immediate_sheet_mutations_ask_without_a_token(self):
        for prefix in ("mcp__plugin_leadmagic_leadmagic__", "mcp__leadmagic__"):
            for name in ("set_sheet_cells", "cancel_sheet_run"):
                for mode in ("default", "acceptEdits", "plan"):
                    with self.subTest(name=name, mode=mode, prefix=prefix):
                        self.assertEqual(self.decision(name, mode, prefix=prefix), "ask")

    def test_preview_calls_and_approved_submits_are_distinct(self):
        for name in ("submit_detected_bulk_job", "delete_sheet_rows", "run_sheet_column"):
            with self.subTest(name=name):
                self.assertEqual(self.decision(name), "allow")
                self.assertEqual(self.decision(name, token="v1.1.sig"), "ask")

    def test_widgets_ask_before_opening(self):
        for name in ("create_bulk_upload_session", "process_attached_csv"):
            with self.subTest(name=name):
                self.assertEqual(self.decision(name), "ask")

    def test_user_selected_automatic_modes_do_not_force_extra_prompts(self):
        for name in ("set_sheet_cells", "cancel_sheet_run", "process_attached_csv", "submit_detected_bulk_job"):
            for mode in ("auto", "dontAsk", "bypassPermissions"):
                with self.subTest(name=name, mode=mode):
                    self.assertEqual(self.decision(name, mode, token="v1.1.sig"), "allow")

    def test_reads_and_pauses_still_run_without_a_prompt(self):
        for name in ("check_credit_balance", "read_sheet_rows", "pause_sheet_run", "pause_bulk_job"):
            with self.subTest(name=name):
                self.assertEqual(self.decision(name), "allow")


if __name__ == "__main__":
    unittest.main()

