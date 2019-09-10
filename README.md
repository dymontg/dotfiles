# Dotfiles
Yes. These are dotfiles.

# Installation
To install, first install the packages listed in `requirements.txt`. On Gentoo, run `xargs emerge < "requirements.txt"`.
Also, run the following to install the task bar.
```
pip install i3-py
git clone https://github.com/krypt-n/bar
cd bar/
make && sudo make install
cd .. && rm -rf bar/
```
Finally, run `bootstrap.sh` to symlink the git repo to the `$HOME` directory.
