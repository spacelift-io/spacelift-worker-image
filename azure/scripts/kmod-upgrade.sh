# Mitigates CVE-2026-31431 (Copy Fail) - upgrades kmod to a version that blocks
# the algif_aead kernel module, which enables local privilege escalation to root.
# More: https://ubuntu.com/blog/copy-fail-vulnerability-fixes-available

sudo apt-get update && sudo apt-get install -y --only-upgrade kmod
