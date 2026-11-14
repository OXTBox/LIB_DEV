# LIB_DEV: notes for AI models
- Every file you make or change for the owner: `python3 -I tools/for_review.py add PATH "work done" "warnings" "caveats"`
  (say the branch in caveats when it is not main).
- Each session: `python3 -I tools/for_review.py feedback` to read the owner's states and feedback;
  act on the feedback and log it in LIB_LLMOUT/Read/LIB_DEV/FEEDBACK_HANDLED.txt. Do NOT move the
  lines: the browser reads REVIEW_STATE.txt and REVIEW_FEEDBACK.txt for its marks and history.
- "Tell Claude" button: it writes a line to LIB_LLMIN/LIB_DEV/TELL_CLAUDE.txt. While a session is
  open, keep `tools/wait_for_tell.sh` running in the background; when it exits, read the feedback,
  act on it, and start it again. At a session start, also check that file for clicks made while away.
