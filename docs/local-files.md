# Local and private configuration

Do not store passwords, tokens, SSH keys, private hostnames, or unpublished
project paths in this repository.

The Bash configuration optionally loads:

```text
~/.config/linux-profile/secrets.sh
```

Create it with restrictive permissions when needed:

```bash
install -m 600 /dev/null ~/.config/linux-profile/secrets.sh
```

Keep machine-specific aliases in an untracked local file or a private
configuration repository.
