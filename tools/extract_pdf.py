"""One-off: extract text from OFFLINE SYNC ARCHITECTURE OVERVIEW.pdf."""
from pathlib import Path

from pypdf import PdfReader

pdf = Path(__file__).resolve().parents[1].parent / "OFFLINE SYNC ARCHITECTURE OVERVIEW.pdf"
out = Path(__file__).resolve().parents[1] / "_offline_sync_doc.txt"

r = PdfReader(str(pdf))
parts = []
for i, p in enumerate(r.pages):
    parts.append(f"---PAGE {i + 1}---\n")
    parts.append(p.extract_text() or "")
    parts.append("\n")
out.write_text("".join(parts), encoding="utf-8")
print("Wrote", out, "pages=", len(r.pages))
