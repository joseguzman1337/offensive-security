"""Add Checkov skip as comments."""

import glob
import logging
import os
import tempfile
from typing import Dict, List, Optional, Tuple, cast

from tqdm import tqdm

# Initialize logging
LOG_FILE = ""
with tempfile.NamedTemporaryFile(mode="w", delete=False, suffix=".log") as tmp_file:
    LOG_FILE = tmp_file.name
os.chmod(LOG_FILE, 0o600)
logging.basicConfig(
    filename=LOG_FILE,
    filemode="w",
    level=logging.INFO,
    format="%(asctime)s - %(levelname)s - %(message)s",
)

# Constants
FRS = "FAILED for resource"
DATES: Dict[str, str] = {
    "python3.7": "2023-06-05",
    "python3.6": "2021-12-23",
}
SKIP_COMMENT_PREFIX = "# checkov:skip="


def remove_duplicate_skips(lines: List[str]) -> List[str]:
    """Remove duplicate skip comments."""
    result = []
    for i, line in enumerate(lines):
        if not (
            line.startswith(SKIP_COMMENT_PREFIX)
            and i > 0
            and lines[i - 1].startswith(SKIP_COMMENT_PREFIX)
            and line == lines[i - 1]
        ):
            result.append(line)
    return result


def add_skip_comment(filename: str, checkov_id: str, start_line: int) -> None:
    """Add skip comment to file."""
    try:
        with open(filename, "r+", encoding="utf-8") as file:
            lines = file.readlines()
            skip_comment = f"{SKIP_COMMENT_PREFIX}{checkov_id}\n"
            if skip_comment not in lines[start_line: start_line + 1]:
                lines.insert(start_line, skip_comment)
                logging.info(
                    "Updated: %s - line %s",
                    filename,
                    start_line + 1,
                )
            else:
                logging.info("Skip exists: %s - %s", filename, checkov_id)
            file.seek(0)
            file.writelines(lines)
            file.truncate()
    except (OSError, IndexError) as error:
        logging.exception("Add skip error: %s - %s", filename, error)


def extract_finding_info(
    lines: List[str], lineno: int
) -> Tuple[Optional[str], Optional[str], Optional[int]]:
    """Extract finding info from log."""
    try:
        _, checkov_id = lines[lineno - 1].split(":", 1)
        file_path, line_range = lines[lineno + 1].split(":")[1:3]
        start_line = int(line_range.split("-")[0])
        return checkov_id.strip(), file_path.strip(), start_line
    except (IndexError, ValueError) as error:
        log_line = lines[lineno] if 0 <= lineno < len(
            lines) else "Out of range"
        logging.error(
            "Extract info error: %s - %s - %s",
            lineno,
            log_line,
            error,
        )
        return None, None, None


def check_deprecated_version(line: str) -> Optional[str]:
    """Checks for deprecated versions."""
    return next((v for v in DATES if v in line), None)


def process_findings(filename: str, lines: List[str]) -> None:
    """Process CKV_AWS_363 findings."""
    for lineno, line in enumerate(lines):
        if "CKV_AWS_363" in line and FRS in line:
            process_finding(filename, lines, lineno)


def process_finding(filename: str, lines: List[str], lineno: int) -> None:
    """Process a single finding."""
    checkov_id, file_path, start_line = extract_finding_info(lines, lineno)
    if checkov_id == "CKV_AWS_363" and all([checkov_id, file_path, start_line]):
        process_ckv_aws_363_finding(filename)


def process_ckv_aws_363_finding(filename: str) -> None:
    """Process a single CKV_AWS_363 finding."""
    for file in os.listdir("."):
        if os.path.isfile(file):
            process_file_finding(filename, file)


def process_file_finding(filename: str, file: str) -> None:
    """Process a single file finding."""
    try:
        with open(file, "r", encoding="utf-8") as f:
            file_lines = f.readlines()
    except FileNotFoundError:
        logging.error("File not found: %s", filename)
        return

    i = 0
    while i < len(file_lines):
        line = file_lines[i]
        if "CKV_AWS_363" in line:
            try:
                file_lines.pop(i)
                file_lines.insert(i + 2, line)
                i += 2
            except IndexError:
                logging.error("Shift line error: %s - %s", file, i)
        else:
            i += 1
    try:
        with open(file, "w", encoding="utf-8") as f:
            f.writelines(file_lines)
    except (OSError, IndexError) as error:
        logging.exception("Write line error: %s - %s", file, error)


def process_file(filename: str) -> None:
    """Process a single file."""
    logging.info("Processing: %s", filename)
    try:
        with open(filename, "r", encoding="utf-8") as file:
            lines = file.readlines()
        process_findings(filename, lines)
    except FileNotFoundError:
        logging.error("File not found: %s", filename)
    logging.info("Finished: %s", filename)


def process_files(pattern: str) -> None:
    """Process files matching a pattern."""
    logging.info("Started.")
    for filename in tqdm(
        glob.glob(pattern),
        desc="Processing files",
        unit="file",
        colour="magenta",
    ):
        process_file(filename)
    reprocess_from_log(LOG_FILE)
    logging.info("All processed.")


def reprocess_from_log(log_file: str) -> None:
    """Re-process findings from the log."""
    try:
        with open(log_file, "r", encoding="utf-8") as file:
            lines = file.readlines()
    except FileNotFoundError:
        logging.error("Log file not found: %s", log_file)
        return

    for line in lines:
        if "Finding not processed" in line:
            reprocess_line(line)


def reprocess_line(line: str) -> None:
    """Reprocess a single line from the log."""
    try:
        _, file_path, checkov_id, start_line_str = line.split(":")
        start_line = int(start_line_str.split()[0])
        add_skip_comment(
            cast(str, file_path.strip()),
            cast(str, checkov_id.strip()),
            start_line - 1,
        )
    except (IndexError, ValueError) as error:
        logging.error("Reprocess error: %s - %s", line, error)


if __name__ == "__main__":
    process_files("git-error-*")
