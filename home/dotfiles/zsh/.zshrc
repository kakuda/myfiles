bindkey -e

autoload -U colors; colors
fpath=(~/.zsh/completion ${fpath})
autoload -U compinit; compinit -u
autoload -U url-quote-magic
zle -N self-insert url-quote-magic
autoload predict-on
zle -N predict-on
zle -N predict-off
bindkey '^X^Z' predict-on
bindkey '^Z' predict-off
zstyle ':predict' verbose true

HISTFILE=$HOME/.zsh-history
HISTSIZE=10000
SAVEHIST=10000

autoload history-search-end
zle -N history-beginning-search-backward-end history-search-end
zle -N history-beginning-search-forward-end history-search-end
bindkey "^p" history-beginning-search-backward-end
bindkey "^n" history-beginning-search-forward-end
bindkey "\\ep" history-beginning-search-backward-end
bindkey "\\en" history-beginning-search-forward-end

setopt extended_history
setopt hist_ignore_all_dups hist_save_nodups
setopt hist_ignore_dups
setopt hist_ignore_space
setopt hist_verify
setopt share_history
setopt append_history
function history-all { history -E 1 }

#setopt auto_cd
#setopt auto_pushd
#setopt auto_list
setopt auto_menu
setopt auto_param_keys
#setopt auto_name_dirs
setopt auto_param_slash
setopt brace_ccl

setopt list_types
setopt magic_equal_subst
setopt menu_complete
setopt numeric_glob_sort
setopt print_eightbit
setopt transient_rprompt
setopt prompt_subst
setopt short_loops
setopt auto_resume
setopt print_eight_bit
setopt correct
setopt extended_glob
setopt always_last_prompt
setopt cdable_vars
setopt sh_word_split
setopt ignore_eof
#setopt list_packed
setopt nolistbeep

if [[ "${OSTYPE}" = darwin* ]] ; then
    export JAVA_HOME=`/usr/libexec/java_home -v 1.7.0_25`
    #export JAVA_HOME=/opt/local/share/java/openjdk6
    export ANT_HOME=/usr/share/ant
    export JRUBY_HOME=/usr/local/jruby
    export CCL_DEFAULT_DIRECTORY=/Applications/ccl
    export HADOOP_HOME=$HOME/local/hadoop
    export PIG_HOME=$HOME/local/pig
    export GRADLE_HOME=/opt/local/share/java/gradle
else
    export JAVA_HOME=/home/y/libexec64/java
    export ANT_HOME=/home/y/libexec/ant
    export JRUBY_HOME=/usr/local/jruby
    export PIG_HOME=$HOME/local/pig
fi
export MVN_HOME=/usr/local/maven
export GOPATH=$HOME/local/gobase
export PATH=$HOME/local/bin:/home/y/bin:/usr/local/php/bin:/usr/local/apache2/bin:$JAVA_HOME/bin:$ANT_HOME/bin:$MVN_HOME/bin:/opt/local/bin:/opt/local/lib/mysql5/bin:/opt/local/apache2/bin:/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin:/usr/games:/usr/X11R6/bin:/opt/gem/bin:$JRUBY_HOME/bin:$HADOOP_HOME/bin:$PIG_HOME/bin:$GOPATH/bin
export LSCOLORS=gxDxcxdxbxexexfxgxfxfx
#export LANG=ja_JP.eucJP
export LANG=C
#export LANG=ja_JP.UTF-8
export PAGER=less
export LESS='-X -i -P ?f%f:(stdin).  ?lb%lb?L/%L..  [?eEOF:?pb%pb\%..]'
#export LESSCHARSET=japanese-euc
export LESSCHARSET=utf-8
#export LESS='cMx4j3'
unset  LESSOPEN
export SVN_EDITOR=vi
export PYTHONPATH=$PYTHONPATH:$HOME/svn/home/libs/python:/System/Library/Frameworks/Python.framework/Versions/Current/lib/python2.6/site-packages
export PYTHONSTARTUP=~/.pythonrc.py
export CVS_RSH=ssh
export CVSROOT=:ext:nakakuda@cvs.dev.yahoo.co.jp:/CVSROOT
export CVSEDITOR=vi

zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'
zstyle ':completion:*:default' menu select=1
zstyle ':completion:*:default' list-colors ${(s.:.)LSCOLORS}
zstyle ':completion:*:sudo:*' command-path /home/y/bin /usr/local/sbin \
                                           /usr/local/bin /usr/sbin /usr/bin /sbin /bin

#PROMPT="[%B%(#.%Broot%b.%n)%b@~%1d]%# "
#RPROMPT='%B(%*)%b'
PROMPT='%{'$'\e[''33m%}(%*)%b%{'$'\e[''m%}%%%u '
PROMPT2='%_%% '
if [ ${YROOT_NAME} ] ; then
    RPROMPT='%{'$'\e[''33m%}[%n@%m(${YROOT_NAME}):%~]%{'$'\e[''m%}'
#     [ -n "${REMOTEHOST}${SSH_CONNECTION}" ] &&
#     PROMPT="%{${fg[white]}%}${HOST%%.*} ${PROMPT}"
else
    RPROMPT='%{'$'\e[''33m%}[%n@%m:%~]%{'$'\e[''m%}'
#     [ -n "${REMOTEHOST}${SSH_CONNECTION}" ] &&
#     PROMPT="%{${fg[white]}%}${HOST%%.*} ${PROMPT}"
fi

function _ej () {
    compadd - $(ruby -ropen-uri -e "print open('http://dictionary.goo.ne.jp/xml/lookupfw.php?MT=$words[2]').read.scan(%r(<cand>(.+?)</cand>)).flatten.join(' ')")
}
compdef _ej ej

# rails generate completion
function _generate () {
  `./script/generate --help | grep '^  [^ ]*: ' | sed 's/[^:]*:/compadd/' | sed 's/\,//g'`
}
compdef _generate generate
compdef _generate destroy

# dabbrev(Ctrl + o)
HARDCOPYFILE=$HOME/.screen-hardcopy
touch $HARDCOPYFILE

function dabbrev-complete () {
    local reply lines=200
    screen -X eval "hardcopy -h $HARDCOPYFILE"
    reply=($(sed '/^$/d' $HARDCOPYFILE | sed '$ d' | tail -$lines))
    compadd - "${reply[@]%[*/=@|]}"
}

zle -C dabbrev-complete menu-complete dabbrev-complete
bindkey '^o' dabbrev-complete
bindkey '^o^_' reverse-menu-complete


if [ "$TERM" = "xterm" -o "$TERM" = "kterm" ]
then
    function _setcaption() { echo -ne  "\e]1;$HOST\a\e]2;$HOST$1\a" > /dev/tty }

    function chpwd() {  print -Pn "\e]2; [%m] : %~\a" }
    chpwd

    function _cmdcaption() { _setcaption " ($1)"; "$@"; chpwd }

    for cmd in telnet slogin ssh rlogin rsh su sudo
    do
      alias $cmd="_cmdcaption $cmd"
    done
elif [ "$TERM" = "dumb" -o "$TERM" = "emacs" ]
then
    PROMPT="%m:%~> "
    unsetopt zle
fi

# show current command on status line
if [ "$TERM" = "screen" ]; then
    chpwd () { echo -n "^[_`dirs`^[\\" }

    preexec() {
        # see [zsh-workers:13180]
        # http://www.zsh.org/mla/workers/2000/msg03993.html
        emulate -L zsh
        local -a cmd; cmd=(${(z)2})
        case $cmd[1] in
            fg)
                if (( $#cmd == 1 )); then
                    cmd=(builtin jobs -l %+)
                else
                    cmd=(builtin jobs -l $cmd[2])
                fi
                ;;
            %*)
                cmd=(builtin jobs -l $cmd[1])
                ;;
            cd|ssh|sudo)
                if (( $#cmd == 2)); then
                    cmd[1]=$cmd[2]
                fi
                ;&
            *)
                echo -n "k$cmd[1]:t\\"
                prev=$cmd[1]
                return
                ;;
        esac

        local -A jt; jt=(${(kv)jobtexts})

        $cmd >>(read num rest
            cmd=(${(z)${(e):-\$jt$num}})
            echo -n "k$cmd[1]:t\\") 2>/dev/null

        prev=$cmd[1]
    }
    precmd() {
        #local prev; prev=`history -1 | sed "s/^[ 0-9]*//" | sed "s/ .*$//"  `
        echo -n "k$:$prev\\"
    }
    chpwd
fi


umask 022

alias vi="vim"
alias -g L="| $PAGER"
alias -g H='| head'
alias -g T='| tail'
alias -g G='| grep'
alias -g W='| wc'
alias -g S='| sed'
alias -g A='| awk'
if [[ "${OSTYPE}" = darwin* ]] ; then
  alias ls="ls -FGv"
else
  alias ls="ls -FG"
fi
alias l="ls -lFG"
alias ll="ls -lFGa"
alias virc="vi ~/.zshrc; source ~/.zshrc"

alias jem="jruby --command gem"
alias jake="jruby --command rake"
alias jails="jruby --command rails"

alias catalog='tail -f /home/maps/tomcat/logs/catalina.out'
alias tomres='/home/maps/tomcat/bin/shutdown.sh; sleep 1; export LANG=ja_JP.eucJP; /home/maps/tomcat/bin/startup.sh; catalog'
alias ssh-nopass='eval `ssh-agent`; ssh-add < /dev/null'

alias lan='repeat 100 /System/Library/PrivateFrameworks/Apple80211.framework/Versions/A/Resources/airport --scan'

# archive
LS_COLORS="no=00:fi=00:di=01;34:ln=01;36:pi=40;33:so=01;35:bd=40;33;01:cd=40;33;01:or=40;31;01:ex=01;32"
#LS_COLORS=":*.rpm=01;31"
LS_COLORS="$LS_COLORS:*.rpm=01;31"
LS_COLORS="$LS_COLORS:*.tar=01;31:*.gz=01;31:*.tgz=01;31:*.z=01;31:*.bz2=01;31"
LS_COLORS="$LS_COLORS:*.lzh=01;31:*.zip=01;31"
LS_COLORS="$LS_COLORS:*.RPM=01;01;31"
LS_COLORS="$LS_COLORS:*.TAR=01;31:*.GZ=01;31:*.TGZ=01;31:*.Z=01;31:*.BZ2=01;31"
LS_COLORS="$LS_COLORS:*.LZH=01;31:*.ZIP=01;31"

# text
LS_COLORS="$LS_COLORS:*.txt=36"
LS_COLORS="$LS_COLORS:*.TXT=36"

# program text
LS_COLORS="$LS_COLORS:*.txc=01;32:*.c=01;32:*.h=01;32"
LS_COLORS="$LS_COLORS:*.TXC=01;32:*.C=01;32:*.H=01;32"

# extra text
LS_COLORS="$LS_COLORS:*.nov=01;32"
LS_COLORS="$LS_COLORS:*.htm=01;34:*.html=01;34"
LS_COLORS="$LS_COLORS:*.NOV=01;32"
LS_COLORS="$LS_COLORS:*.HTM=01;34:*.HTML=01;34"

# multi media
LS_COLORS="$LS_COLORS:*.mp3=01;35:*.mid=01;35:*.wav=01;35:*.mod=01;35"
LS_COLORS="$LS_COLORS:*.avi=01;35:*.mov=01;35:*.mpg=01;35:*.mpeg=01;35"
LS_COLORS="$LS_COLORS:*.MP3=01;35:*.MID=01;35:*.WAV=01;35:*.MOD=01;35"
LS_COLORS="$LS_COLORS:*.AVI=01;35:*.MOV=01;35:*.MPG=01;35:*.MPEG=01;35"

# graphics
LS_COLORS="$LS_COLORS:*.jpg=01;33:*.jpeg=01;33:*.bmp=01;33:*.gif=01;33:*.png=01;33"
LS_COLORS="$LS_COLORS:*.xpm=01;33:*.xbm=01;33:*.xwd=01;33:*.xcf=01;33"
LS_COLORS="$LS_COLORS:*.JPG=01;33:*.JPEG=01;33:*.BMP=01;33:*.GIF=01;33:*.PNG=01;33"
LS_COLORS="$LS_COLORS:*.XPM=01;33:*.XBM=01;33:*.XWD=01;33:*.XCF=01;33"

# for GNU ls
export LS_COLORS

[ -f /opt/boxen/env.sh ] && source /opt/boxen/env.sh
[ -f /opt/boxen/nvm/nvm.sh ] && source /opt/boxen/nvm/nvm.sh
