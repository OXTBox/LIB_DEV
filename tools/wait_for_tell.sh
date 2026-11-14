#!/usr/bin/env bash
# wait_for_tell.sh - the AI's side of the Status_Browser's "Tell Claude" button.
# Waits (checking every 3 s) until LIB_LLMIN/LIB_DEV/TELL_CLAUDE.txt gets a new line, prints it, exits.
# The AI runs it in the background while a session is open; when it exits the AI is notified,
# reads the reviews (tools/for_review.py feedback), acts, and starts it again.
F=/home/igame3d/projects/LIB_LLMIN/LIB_DEV/TELL_CLAUDE.txt
count() { [ -f "$F" ] && wc -l < "$F" || echo 0; }
START=$(count)
while [ "$(count)" -le "$START" ]; do sleep 3; done
echo "TELL CLAUDE: the owner asks for a review of the reviews"
tail -n +$((START + 1)) "$F"
