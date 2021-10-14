# zsh-bench

Benchmark for interactive zsh.

- [Summary](#summary)
- [Install](#install)
- [Usage](#usage)
- [How it works](#how-it-works)
- [What it measures](#what-it-measures)
- [How fast is fast](#how-fast-is-fast)
- [Benchmark results](#benchmark-results)
  - [Basics](#basics)
  - [Prompt](#prompt)
  - [Premade configs](#premade-configs)
  - [Do it yourself](#do-it-yourself)
  - [Cutting corners](#cutting-corners)
  - [Powerlevel10k](#powerlevel10k)
    - [Instant prompt](#instant-prompt)
  - [Plugin managers](#plugin-managers)
  - [Deferred initialization](#deferred-initialization)
  - [How not to benchmark](#how-not-to-benchmark)
  - [Full benchmark data](#full-benchmark-data)
  - [Conclusions](#conclusions)
- [License](#license)
- [FAQ](#faq)

## Summary

- `zsh-bench` measures user-visible latency of interactive zsh: *input lag*, *command lag*, etc. You
  can [use it to benchmark your own shell](#usage).
- `human-bench` measures human perception of latency when using interactive zsh. You can use it to
  check how it feels to use zsh with specific latencies or to test whether you can tell a
  difference between 5ms and 0ms *command lag*.
- I've used `human-bench` to conduct a blind study on myself to find the maximum values of latencies
  that are indistinguishable from zero. For example, *command lag* below 10ms feels just like 0ms
  but anything above this value starts feeling sluggish.
- I've used these threshold values to normalize benchmark results to see what is fast and what is
  slow.
- Armed with this set of tools I've optimized two of my zsh projects:
  [powerlevel10k](https://github.com/romkatv/zsh4humans) and
  [zsh4humans](https://github.com/romkatv/zsh4humans). They used to be fairly fast but now they
  are literally indistinguishable from instantaneous as far as human perception goes.
- I've benchmarked many zsh techniques, plugins, frameworks and plugin managers and have shared
  [my observations](#benchmark-results) in this document together with a brief
  [conclusion](#conclusions).

## Install

Clone the repo:

```zsh
git clone https://github.com/romkatv/zsh-bench ~/zsh-bench
```

## Usage

### Benchmark zsh on your machine

```zsh
~/zsh-bench/zsh-bench
```

This requires zsh >= 5.8 and it must be your login shell. It also requires `script` utility from
util-linux. The BSD version is current not supported although with enough dedication this can be
done. A PR would be most appreciated.

If your zsh startup files start `tmux`, the benchmark may hang unless your `tmux` has [this fix](
  https://github.com/tmux/tmux/commit/9b1fdb291ee8e940311a51cf41f97b07930b4688#diff-2dec3ca953f8622e2bc9fe13a2eb464d057905e6f9313682665328c6b67910e6)
for [this bug](https://github.com/tmux/tmux/issues/2909).

If your zsh startup files enable history but don't set `histignorespace`, you might find random
commands in your history after running `zsh-bench`.

### Benchmark predefined zsh configs

```zsh
~/zsh-bench/zsh-bench <name> [name]..
```

This requires `docker`. Names of predefined zsh configs are directories under
[configs](https://github.com/romkatv/zsh-bench/tree/master/configs).

## How it works

`zsh-bench` creates a virtual TTY and starts a login shell in it. It then sends keystrokes to the
TTY and measures how long it takes for the shell to react. For example, `zsh-bench` can send
`echo hello` and `echo goodbye` to the TTY twice in quick succession and measure how long it takes
for the words "hello" and "goodbye" to be printed.

## What it measures

Sample output of `zsh-bench`:

```text
creates_tty=1
has_compsys=1
has_syntax_highlighting=1
has_autosuggestions=1
has_git_prompt=1
first_prompt_lag_ms=14.331
first_command_lag_ms=56.500
command_lag_ms=2.518
input_lag_ms=5.195
exit_time_ms=5.886
```

The first few fields list detected shell capabilities; the rest are measured latencies.

Shell capabilities (0 or 1):

| name | meaning |
|------------|---------|
| **creates tty** | the shell creates its own TTY by invoking `tmux` or `screen` |
| **has compsys** | the shell initializes `compsys`—the "new" completion system—by invoking `compinit` |
| **has syntax highlighting** | user input (the command line) is highlighted by [zsh-syntax-highlighting](https://github.com/zsh-users/zsh-syntax-highlighting) |
| **has autosuggestions** | suggestions for command completions are offered automatically by [zsh-autosuggestions](https://github.com/zsh-users/zsh-autosuggestions) |

Latencies (in milliseconds):

| name | what time it measures | if too high |
|------|-----------------------|-------------|
| **first prompt lag (ms)** | from the start of the shell to the moment prompt appears on the screen | you get to stare at an empty screen for some time whenever you open a terminal |
| **first command lag (ms)** | from the start of the shell to the moment the first interactive command starts executing | you get to wait for the output of `ls` if you type it really fast after opening a terminal |
| **command lag (ms)** | from pressing <kbd>Enter</kbd> on an empty command line to the moment the next prompt appears; the same as [zsh-prompt-benchmark](https://github.com/romkatv/zsh-prompt-benchmark) (my project) | all commands appear to take longer to execute; the slowdown may happen after you press <kbd>Enter</kbd> and before the command starts executing, or before the command finishes executing and the next prompt appears |
| **input lag (ms)** | from pressing a regular key to the moment the corresponding character appears on the command line; this test is perform when the current command line is already fairly long | keyboard input feels sluggish, as if you are working over an SSH connection with high latency |
| **exit time (ms)** | how long it takes to execute `zsh -lic "exit"`; this value is [meaningless](#how-not-to-benchmark) as far as measuring interactive shell latencies goes | there is no baseline value for this latency, so it cannot be "too high" |

## How fast is fast

Is *input lag* of 5ms a lot? What about *first prompt lag* of 100ms? How good/bad would it
be if these latencies were halved/doubled? I've written `human-bench` to answer questions like this.
It's a small tool that can simulate zsh with latencies of your choice.

```text
usage: human-bench [OPTION]..

OPTIONS
  -h,--help
  -s,--shell-command <STR> [default="zsh"]
  -f,--first-prompt-lag-ms <NUM> [default=0]
  -c,--first-command-lag-ms <NUM> [default=0]
  -p,--command-lag-ms <NUM> [default=0]
  -i,--input-lag-ms <NUM> [default=0]
```

It turns out that *first prompt lag* of 100ms causes the first prompt to appear with a noticeable
delay when starting zsh but *input lag* of 5ms is barely perceptible. Or is it imperceptible?
When I invoke `human-bench --input-lag-ms 5` I expect input to lag and this might affect what I'm
seeing. To rule out this bias I've extended `human-bench` to accept several values of the same
latency:

```zsh
human-bench --input-lag-ms 0 --input-lag-ms 5
```

`human-bench` picks one of these latencies at random before starting zsh. However, it doesn't
reveal the choice until I exit the playground. With this tool in hand I conducted a blind study on
myself and found out that I cannot distinguish between these two latencies. As far as my senses are
concerned, *input lag* of 5ms is as good as zero.

I used this blinding method to find the threshold values of all latencies in my use of zsh. Any
value below the threshold is—to me—indistinguishable from zero. I can distinguish values above the
threshold from zero with better than 50% accuracy.

| latency (ms)          | the maximum value indistinguishable from zero |
|-----------------------|----------------------------------------------:|
| **first prompt lag**  |                                            50 |
| **first command lag** |                                           150 |
| **command lag**       |                                            10 |
| **input lag**         |                                            20 |

The first two latencies are related to zsh startup time. I don't start zsh by literally typing `zsh`
within an existing shell. I either open a terminal, create a new tab, or split an existing tab. The
latter is the most common, so I rigged `human-bench` to split a tab for the purpose of testing
startup latencies. For the other two latencies I typed and executed simple commands.

Keep in mind that these thresholds may have different values for different people, machines,
terminals, etc. I believe the ballpark should be the same though.

## Benchmark results

I implemented `zsh-bench` in order to optimize [powerlevel10k](https://github.com/romkatv/zsh4humans)
and [zsh4humans](https://github.com/romkatv/zsh4humans). In the process I benchmarked many zsh
techniques, plugins, frameworks and plugin managers. I'm sharing some of my findings here.

I recommend reading this section top-to-bottom without jumping back and forth. You can also skip
right to [conclusions](#conclusions).

All benchmark results in this section have been normalized by the
[threshold values](#how-fast-is-fast). *first prompt lag* of 25ms becomes 50% and 100ms becomes
200%. Latencies up to 50%, 100% and 200% are be marked with 🟢, 🟡 and 🟠, respectively. Latencies
above 200% get 🔴. Note that 🟡 is actually *really good*. It means the latency is
indistinguishable from zero. A zsh config with all latencies marked green or yellow performs as if
there were no latencies at all. I'm reserving 🟢 for latencies under *half* of this ambitious
threshold because it's nice to have a bit of headroom. I might add extra stuff to my zsh configs or
maybe I'll run zsh on a slower machine. I wouldn't want this to push my latencies outside of the
imperceptible range. So, green latencies aren't just imperceptible but also leave enough unused
latency budget.

### Basics

| config | tmux | compsys | syntax highlight | auto suggest | git prompt | first prompt lag | first cmd lag | cmd lag | input lag |
|-|-:|-:|-:|-:|-:|-:|-:|-:|-:|
| [no-rcs](https://github.com/romkatv/zsh-bench/tree/master/configs/no-rcs) | ❌ | ❌ | ❌ | ❌ | ❌ | 2%<br>🟢 | 1%<br>🟢 | 1%<br>🟢 | 1%<br>🟢 |
| [tmux](https://github.com/romkatv/zsh-bench/tree/master/configs/tmux) | ✔️ | ❌ | ❌ | ❌ | ❌ | 17%<br>🟢 | 6%<br>🟢 | 1%<br>🟢 | 1%<br>🟢 |
| [compsys](https://github.com/romkatv/zsh-bench/tree/master/configs/compsys) | ❌ | ✔️ | ❌ | ❌ | ❌ | 37%<br>🟢 | 12%<br>🟢 | 1%<br>🟢 | 1%<br>🟢 |
| [zsh-syntax-highlighting](https://github.com/romkatv/zsh-bench/tree/master/configs/zsh-syntax-highlighting) | ❌ | ❌ | ✔️ | ❌ | ❌ | 1%<br>🟢 | 7%<br>🟢 | 6%<br>🟢 | 58%<br>🟡 |
| [zsh-autosuggestions](https://github.com/romkatv/zsh-bench/tree/master/configs/zsh-autosuggestions) | ❌ | ❌ | ❌ | ✔️ | ❌ | 32%<br>🟢 | 13%<br>🟢 | 99%<br>🟡 | 5%<br>🟢 |
| [git-branch](https://github.com/romkatv/zsh-bench/tree/master/configs/git-branch) | ❌ | ❌ | ❌ | ❌ | ✔️ | 26%<br>🟢 | 9%<br>🟢 | 47%<br>🟢 | 1%<br>🟢 |

**no-rcs** is zsh in its pure form, without any
[rc files](https://zsh.sourceforge.io/Intro/intro_3.html). It's really fast! Even if it was 50 times
slower, I wouldn't be able to tell a difference.

The rest of the entries here are the simplest configs capable of providing each capability. For
example, here's `.zshrc` from **zsh-autosuggestions**:

```zsh
source ~/zsh-autosuggestions/zsh-autosuggestions.zsh
```

Just one line. Plain and simple. `~/zsh-autosuggestions` is supposed to be created manualy, outside
of zsh rc files. In the benchmark it's done by a `setup` script like this:

```zsh
git clone -q --depth=1 https://github.com/zsh-users/zsh-autosuggestions.git ~/zsh-autosuggestions
```

These basic building blocks are composable. We can easily create a config by combining any number
of them. Later we'll be doing just that. The latencies of a combination are the sums of latencies
of all its constituents. For example, *first prompt lag* of **tmux+compsys** is *first prompt lag*
of **tmux** plus *first prompt lag* of **compsys**. You can probably already see that adding
everything together will push some latencies over the threshold. Our goal is to avoid that while
still getting all the goodies. **git-branch** gives us *git prompt* for the price of 47% of our
*command lag* budget. Let's see if we can do better.

### Prompt

I've benchmarked several different git prompts.

| config | tmux | compsys | syntax highlight | auto suggest | git prompt | first prompt lag | first cmd lag | cmd lag | input lag |
|-|-:|-:|-:|-:|-:|-:|-:|-:|-:|
| [git-branch](https://github.com/romkatv/zsh-bench/tree/master/configs/git-branch) | ❌ | ❌ | ❌ | ❌ | ✔️ | 26%<br>🟢 | 9%<br>🟢 | 47%<br>🟢 | 1%<br>🟢 |
| [agnoster](https://github.com/romkatv/zsh-bench/tree/master/configs/agnoster) | ❌ | ❌ | ❌ | ❌ | ✔️ | 58%<br>🟡 | 20%<br>🟢 | 219%<br>🔴 | 1%<br>🟢 |
| [powerlevel10k](https://github.com/romkatv/zsh-bench/tree/master/configs/powerlevel10k) | ❌ | ❌ | ❌ | ❌ | ✔️ | 4%<br>🟢 | 13%<br>🟢 | 19%<br>🟢 | 1%<br>🟢 |

The git repo used by the benchmark has 1,000 directories and 10,000 files in it. Not too few,
not too many. All benchmarks ran with untracked cache enabled. Wall time of `git status` stood at
14.7ms.

**git-branch** only shows the name of the current branch and has the same latency regardless of the
repository size.

**agnoster** config uses the classic
[agnoster zsh theme](https://github.com/agnoster/agnoster-zsh-theme). It scans the whole repo to see
if there are untracked files, unstaged changes, etc. We can see that this causes lag on every
command pushing latency into the red. The lag is linear in the number of files and directories in
the git repo. You wouldn't want to use this theme in a truly large git repo with hudreds of
thousands or millions of files.

**powerlevel10k** config uses [powerlevel10k zsh theme](https://github.com/romkatv/powerlevel10k)
that I've developed. It scans the git repo just like agnoster but it does not invoke `git` to do
that. Instead, it uses [gitstatus](https://github.com/romkatv/gitstatus) -- another of my
projects. This gives powerlevel10k a nice speedup on repositories large and small. In addition,
powerlevel10k doesn't block zsh prompt while gitstatus is scanning the repo, so *command lag* stays
constant even in giant repositories. Powerlevel10k has a few other interesting performance-related
properties that we'll [explore](#powerlevel10k) when we start building real zsh configs.

### Premade configs

Let's see what some of the popular premade zsh configs offer out of the box.

| config | tmux | compsys | syntax highlight | auto suggest | git prompt | first prompt lag | first cmd lag | cmd lag | input lag |
|-|-:|-:|-:|-:|-:|-:|-:|-:|-:|
| [prezto](https://github.com/romkatv/zsh-bench/tree/master/configs/prezto) | ❌ | ✔️ | ❌ | ❌ | ❌ | 98%<br>🟡 | 35%<br>🟢 | 13%<br>🟢 | 1%<br>🟢 |
| [ohmyzsh](https://github.com/romkatv/zsh-bench/tree/master/configs/ohmyzsh) | ❌ | ✔️ | ❌ | ❌ | ✔️ | 285%<br>🔴 | 97%<br>🟡 | 836%<br>🔴 | 1%<br>🟢 |
| [zim](https://github.com/romkatv/zsh-bench/tree/master/configs/zim) | ❌ | ✔️ | ✔️ | ✔️ | ✔️ | 228%<br>🔴 | 88%<br>🟡 | 858%<br>🔴 | 68%<br>🟡 |
| [zsh4humans](https://github.com/romkatv/zsh-bench/tree/master/configs/zsh4humans) | ✔️ | ✔️ | ✔️ | ✔️ | ✔️ | 28%<br>🟢 | 35%<br>🟢 | 25%<br>🟢 | 26%<br>🟢 |

The names of these configs match the respective public projects from which they were copied:
[ohmyzsh](https://github.com/ohmyzsh/ohmyzsh), [prezto](https://github.com/sorin-ionescu/prezto),
[zim](https://github.com/zimfw/zimfw) and [zsh4humans](https://github.com/romkatv/zsh4humans). The
latter is my project. All configs were used unmodified.

**prezto** is very fast but also doesn't provide much out of the box. No syntax highlighting,
autosuggestions or git prompt. Users who need these features—most do—should enable them explicitly.

**ohmyzsh** and **zim** by default use a theme with similar performance characteristics of
**agnoster**, so they have high *command lag* in larger git repositories.

**zim** has high latencies across the board. Some of it is fixable by swapping its default theme
for a more efficient one. The remainder of surplus latency compared to other projects is caused by
the relatively high number of features that zim enables by default. In fact, all these projects
have extra features that aren't reflected in the capabilities shown in the table but other projects
appear to be more careful in choosing what to enable by default than **zim**.

**zsh4humans** ticks all capability checkboxes and has all latencies comfortably in the green zone.
This shouldn't be surprising. In the game of optimization, measuring is half the work. I had access
to `zsh-bench`, so I was able to optimize zsh4humans to score well on it. Prior to creating
`zsh-bench` I knew that *input lag* and *first command lag* in zsh4humans were sometimes noticeable
but it was difficult to evaluate the effectiveness of potential optimizations when I not only
couldn't measure these latencies but didn't even have clear concepts for them.

### Do it yourself

Let's leave premade configs alone for some time and try to build a zsh config from scratch. Given
the availability of high-quality building blocks, this shouldn't be very difficult.

| config | tmux | compsys | syntax highlight | auto suggest | git prompt | first prompt lag | first cmd lag | cmd lag | input lag |
|-|-:|-:|-:|-:|-:|-:|-:|-:|-:|
| [diy](https://github.com/romkatv/zsh-bench/tree/master/configs/diy) | ✔️ | ✔️ | ✔️ | ✔️ | ✔️ | 124%<br>🟠 | 49%<br>🟢 | 156%<br>🟠 | 63%<br>🟡 |
| [diy+](https://github.com/romkatv/zsh-bench/tree/master/configs/diy%2B) | ✔️ | ✔️ | ✔️ | ✔️ | ✔️ | 18%<br>🟢 | 54%<br>🟡 | 25%<br>🟢 | 66%<br>🟡 |
| [diy++](https://github.com/romkatv/zsh-bench/tree/master/configs/diy%2B%2B) | ✔️ | ✔️ | ✔️ | ✔️ | ✔️ | 18%<br>🟢 | 45%<br>🟢 | 25%<br>🟢 | 66%<br>🟡 |

**diy** is the simplest config that provides all capabilities. I've made it by concatenating configs
of the [basic building blocks](#basics). Here's the whole `.zshrc`:

```zsh
# If not in tmux, start tmux.
if [[ -z ${TMUX+X}${ZSH_SCRIPT+X}${ZSH_EXECUTION_STRING+X} ]]; then
  exec tmux
fi

# Enable the "new" completion system (compsys).
autoload -Uz compinit && compinit

# Configure prompt to show the current working directory and git branch.
autoload -Uz vcs_info add-zsh-hook
add-zsh-hook precmd vcs_info
PS1='%~ $vcs_info_msg_0_'
setopt prompt_subst

# Enable syntax highlighting.
source ~/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
# Enable autosuggestions.
source ~/zsh-autosuggestions/zsh-autosuggestions.zsh
```

Two latencies are over the threshold, so some lag can be noticeable. However, before using this
config you'll want to add more stuff to it -- key bindings, environment variables, aliases,
completions options, etc. All these things will make zsh slower. If you aren't careful, a lot
slower.

**diy+** improves on **diy** by replacing its prompt with [powerlevel10k](#powerlevel10k). This has
dramatic positive effect on *first prompt lag* and *command lag*. Moreover, *first prompt lag*
is now constant and won't increase if more stuff is added to the config. This means you'll never
have to stare at an empty screen when opening terminal -- prompt will be there right from the start.
The additional initialization code will only affect *first command lag*, which has the highest
threshold of all latencies and has the least impact on the perception of zsh performance. I've also
made `.zshrc` in this config self-bootstrapping to obviate the need to maintain a separate `install`
or `setup` script for the cloning of zsh plugin repositories. This is primarily to make comparisons
with plugin managers in the future sections easier.

**diy++** adds one more optimization -- it compiles large zsh files to wordcode. This reduces
*first command lag* a little bit. This config performs well and is still
[relatively simple](https://github.com/romkatv/zsh-bench/blob/master/configs/diy%2B%2B/skel/.zshrc).

### Cutting corners

There are several optimizations that speed up zsh startup but can easily backfire. **diy++unsafe**
adds three such optimizations on top of **diy++** to reduce *first command lag* by 5%. I don't
recommend them.

| config | tmux | compsys | syntax highlight | auto suggest | git prompt | first prompt lag | first cmd lag | cmd lag | input lag |
|-|-:|-:|-:|-:|-:|-:|-:|-:|-:|
| [diy++unsafe](https://github.com/romkatv/zsh-bench/tree/master/configs/diy%2B%2Bunsafe) | ✔️ | ✔️ | ✔️ | ✔️ | ✔️ | 18%<br>🟢 | 40%<br>🟢 | 25%<br>🟢 | 66%<br>🟡 |

The first optimization is to compile to wordcode `.zshrc` itself. This will cause you a lot of grief
if you do something like this:

```zsh
% cp ~/.zshrc ~/.zshrc.bak  # backup .zshrc before messing with it
% vi ~/.zshrc               # change stuff
% exec zsh                  # restart zsh to try the new changes
% mv ~/.zshrc.bak ~/.zshrc  # revert changes
% exec zsh                  # restart zsh
```

At this point you'll be surprised to find that the last command seemingly had no effect. Zsh is
still using `.zshrc` that you modified in `vi`. This happens because `mv` preserves file
modification time and zsh looks at it to figure out whether the wordcode matches the source code.

Compiling `.zshrc` to wordcode will also prevent you from using aliases in `.zshrc` if they were
defined in the same file. For example:

```zsh
alias ll='ls -l'
lll() { ll "$@" | less; }
```

If you put this code in `.zshrc`, you'll notice that `lll` doesn't work if `.zshrc` is compiled.

Another dangerous optimization is to invoke `compinit` with `-C`. If you do that and install a new
tool using your favorite package manager, completions for this tool may not appear in zsh even after
restart. You'll have to manually delete a cache file. Saving a few milliseconds on zsh startup is
not worth it if later you'll have to spend an hour trying to figure out why completions don't work.

The last over-eager optimization is to print the first prompt before checking whether plugins
need to be installed. The section on [Instant Prompt](#instant-prompt) explains why this is a bad
idea.

### Powerlevel10k

Before going further let's look at powerlevel10k more closely. This theme can display a lot of
information in prompt: disk usage, public IP address, VPN status, current kubernetes context,
taskwarrior task count, etc. The configuration of powerlevel10k affects its latency. All benchmarked
configs that use powerlevel10k employ the same small config that only shows the current working
directory and git status in prompt. In addition to this I've also measured (and optimized -- this
was the whole point of working on `zsh-bench`) the performance of powerlevel10k with *everything*
turned on.

| config | tmux | compsys | syntax highlight | auto suggest | git prompt | first prompt lag | first cmd lag | cmd lag | input lag |
|-|-:|-:|-:|-:|-:|-:|-:|-:|-:|
| [powerlevel10k](https://github.com/romkatv/zsh-bench/tree/master/configs/powerlevel10k) | ❌ | ❌ | ❌ | ❌ | ✔️ | 4%<br>🟢 | 13%<br>🟢 | 19%<br>🟢 | 1%<br>🟢 |
| [powerlevel10k-full](https://github.com/romkatv/zsh-bench/tree/master/configs/powerlevel10k-full) | ❌ | ❌ | ❌ | ❌ | ✔️ | 7%<br>🟢 | 27%<br>🟢 | 67%<br>🟡 | 7%<br>🟢 |

**powerlevel10k-full** has substantially higher *command lag* but it's still under 100%, meaning
that prompt is still indistinguishable from instantaneous. However, there is not much *command lag*
budget left for doing extra things on every command. So you would need to be careful with your zsh
config if you were to use powerlevel10k with everything turned on. In practice, no sane person would
enable *everything*. Here's a ridiculously overwrought prompt:

![Powerlevel10k Extravagant Style](
  https://raw.githubusercontent.com/romkatv/powerlevel10k-media/master/extravagant-style.png)

It has **18** segments. The full config enables **64**!

Notice that **powerlevel10k-full** also increases *input lag* by 6% (that's 1.3ms) compared to the
smaller config. Powerlevel10k can dynamically update prompt depending on the current command you are
typing. Here's an example from powerlevel10k docs where the current kubernetes context and gcloud
credentials are shown only when they are relevant to the current command.

<details>
  <summary>Powerlevel10k Show On Command</summary>

  ![Powerlevel10k Show On Command](
    https://raw.githubusercontent.com/romkatv/powerlevel10k-media/master/show-on-command.gif)
</details>

This feature requires parsing the command line as it changes, hence extra **input lag**. The impact
on latency is small, so it shouldn't cause any problems.

#### Instant prompt

I mentioned earlier that powerlevel10k makes *first prompt lag* small and, importantly, independent
from anything else you have in zsh startup files. This feature is called *Instant Prompt* in
powerlevel10k docs (a more appropriate name would have been *Instant **First** Prompt*) and it's
worth looking at how it works.

When you open the homepage of Google in a web browser, it appears to load almost instantly even
though there is a lot of fancy functionality built into it. If we look under the hood, the whole
page takes a long time to load but most of this loading happens after the UI has been rendered. It
doesn't take much time to render an input box for the query and the search button, so it looks
instantaneous. The initial UI may look like the real thing but it's only a stub. If you enter a
query and click the button quickly enough, search results won't appear. The button doesn't have the
necessary logic yet, so it'll just remember that it was clicked. The query will go through once the
page loads.

This trick works really well because you can start typing right away. Typing is very slow by machine
standards, so by the time you are finished the page has almost always been fully loaded and you
don't notice any delay when clicking the button.

Powerlevel10k uses the same trick, only in case of zsh the UI you see on startup is the prompt.
As soon as you open a terminal, powerlevel10k prints prompt. This first prompt only has information
that can be computed quickly (the current working directory, username, hostname, current time,
python virtual environment, etc.) but nothing that can require a lot of time, so no git status.
While you are typing the first command, zsh continues to initialize -- loading plugins, setting up
completions, defining aliases, enabling key bindings, retrieving git status, etc. Once zsh is fully
initialized, the original limited prompt is replaced with the full prompt and whatever you have
typed is replayed in Zsh Line Editor (zle). If you've enabled syntax highlighting, at this point the
command line gets highlighted. Here's how it looks:

<details>
  <summary>Powerlevel10k Instant Prompt</summary>

  ![Powerlevel10k Instant Prompt](
    https://raw.githubusercontent.com/romkatv/powerlevel10k-media/master/instant-prompt.gif)
</details>

If you press <kbd>Enter</kbd> before zsh is fully initialized, the command won't execute. It
*cannot* execute because execution relies on aliases, environment variables and whatnot, but those
things haven't been defined yet. The command will execute once zsh finishes initializing. Until then
it'll look like lag, as if the command takes a long time to start. You'll notice the same "lag" if
you use a key binding such as <kbd>Tab</kbd> for a completion or <kbd>Ctrl+R</kbd> for interactive
history search.

Initializing zsh while you are typing the first command poses a problem. What if some part of
`.zshrc` prints to the terminal? The output will appear smack in the middle of what you percieve as
the command line. That wouldn't be pretty at all. And what if `.zshrc` asks you a question?

```text
Disk usage seems kinda high. Delete your home directory? [y/N]
```

The buffered input that was intended to go to Zsh Line Editor will be read by the disk cleaner. If
the first command you are typing starts with "y", say goodbye to your files.

To avoid these issues, for the duration of zsh initialization powerlevel10k redirects standard input
to `/dev/null` and standard output with standard error to a temporary file. Once zsh is fully
initialized, standard file descriptors are restored and the content of the temporary file is printed
out. This content appears *above* the first prompt. This is much better than letting the output
interleave with the command line but it's still not pretty.

For best results, when using *Instant Prompt*, `.zshrc` should be structured like so:

1. The first section is for commands that either:
   - read from standard input or the TTY
   - write to standard output, standard error or the TTY
   - occasionally (but rarely) may take unpredictably long time to execute
   ```zsh
   # If not in tmux, start tmux: reads and writes the TTY.
   if [[ -z ${TMUX+X}${ZSH_SCRIPT+X}${ZSH_EXECUTION_STRING+X} ]]; then
     exec tmux
   fi

   # Clone git repos that don't exist: prints and may take unpredictably long time to execute.
   if [[ ! -e ~/zsh-autosuggestions ]]; then
     print -r -- 'installing zsh-autosuggestions ...'
     git clone --depth=1 https://github.com/zsh-users/zsh-autosuggestions.git ~/zsh-autosuggestions
   fi

   # Prints.
   print -Pr -- 'Hello, %n. Today is %D{%A}.'

   # ... and so on
   ```
2. Activate *Instant Prompt*. This must be done with this exact command.
   ```zsh
   # Print the first prompt and redirect standard file descriptors.
   if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
     source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
   fi
   ```
3. The last section is for the bulk of initialization. These commands must not:
     - read from standard input or the TTY
     - write to standard output, standard error or the TTY
     - take unpredictably long time to execute
   ```zsh
    autoload -Uz compinit && compinit
    source ~/zsh-autosuggestions/zsh-autosuggestions.zsh
    # ... and so on
   ```

Commands in the first section must be very fast to avoid delaying the first prompt.

It's OK for commands in the last section to print in case of errors. The assumption is that you'll
fix these errors, so in normal operation there won't be any output.

If you need to use the TTY in the last section, there is `$TTY` for you. Just make sure you aren't
reading anything from it and only writing "invisible" things that don't appear on the screen. This
is OK:

```zsh
# Let gpg know what our TTY is.
export GPG_TTY=$TTY
# Change cursor shape to "beam".
print -n '\e[5 q' >$TTY
# Display the current working directory in the terminal title.
printf '\e]0;%s\a' ${(V)${(%):-%1~}} >$TTY
```

### Plugin managers

**diy++** is a solid base for a zsh config that gives us full control over the initialization
process. By using a plugin manager we can give up some of this control for convenience. I've
benchmarked several plugin managers and frameworks. All configs here have all core capabilities.

| config | tmux | compsys | syntax highlight | auto suggest | git prompt | first prompt lag | first cmd lag | cmd lag | input lag |
|-|-:|-:|-:|-:|-:|-:|-:|-:|-:|
| [diy++](https://github.com/romkatv/zsh-bench/tree/master/configs/diy%2B%2B) | ✔️ | ✔️ | ✔️ | ✔️ | ✔️ | 18%<br>🟢 | 45%<br>🟢 | 25%<br>🟢 | 66%<br>🟡 |
| [diy++unsafe](https://github.com/romkatv/zsh-bench/tree/master/configs/diy%2B%2Bunsafe) | ✔️ | ✔️ | ✔️ | ✔️ | ✔️ | 18%<br>🟢 | 40%<br>🟢 | 25%<br>🟢 | 66%<br>🟡 |
| [zcomet](https://github.com/romkatv/zsh-bench/tree/master/configs/zcomet) | ✔️ | ✔️ | ✔️ | ✔️ | ✔️ | 18%<br>🟢 | 46%<br>🟢 | 25%<br>🟢 | 66%<br>🟡 |
| [zinit](https://github.com/romkatv/zsh-bench/tree/master/configs/zinit) | ✔️ | ✔️ | ✔️ | ✔️ | ✔️ | 18%<br>🟢 | 80%<br>🟡 | 25%<br>🟢 | 69%<br>🟡 |
| [zplug](https://github.com/romkatv/zsh-bench/tree/master/configs/zplug) | ✔️ | ✔️ | ✔️ | ✔️ | ✔️ | 108%<br>🟠 | 101%<br>🟠 | 25%<br>🟢 | 68%<br>🟡 |
| [ohmyzsh+](https://github.com/romkatv/zsh-bench/tree/master/configs/ohmyzsh%2B) | ✔️ | ✔️ | ✔️ | ✔️ | ✔️ | 18%<br>🟢 | 59%<br>🟡 | 30%<br>🟢 | 67%<br>🟡 |
| [prezto+](https://github.com/romkatv/zsh-bench/tree/master/configs/prezto%2B) | ✔️ | ✔️ | ✔️ | ✔️ | ✔️ | 22%<br>🟢 | 54%<br>🟡 | 36%<br>🟢 | 74%<br>🟡 |
| [zim+](https://github.com/romkatv/zsh-bench/tree/master/configs/zim%2B) | ✔️ | ✔️ | ✔️ | ✔️ | ✔️ | 18%<br>🟢 | 42%<br>🟢 | 25%<br>🟢 | 72%<br>🟡 |
| [zsh4humans](https://github.com/romkatv/zsh-bench/tree/master/configs/zsh4humans) | ✔️ | ✔️ | ✔️ | ✔️ | ✔️ | 28%<br>🟢 | 35%<br>🟢 | 25%<br>🟢 | 26%<br>🟢 |

**diy++** and **diy++unsafe** are listed here to serve as baseline for comparing latency.

The next three configs use "pure" plugin managers: [zcomet](https://github.com/agkozak/zcomet),
[zinit](https://github.com/zdharma/zinit) and [zplug](https://github.com/zplug/zplug). These allow
you to install and load plugins but don't configure zsh on their own in any way.

Configs **ohmyzsh+**, **prezto+** and **zim+** are based on the respective standard configs. I've
enabled only the plugins that are required to tick off all capabilities and disabled the rest.

**zsh4humans** can install and load arbitrary plugins but the default config already enables
everything we care about. So I'm benchmarking the stock config with no changes here.

All configs in this list except for **zsh4humans** treat [zsh-syntax-highlighting](
  https://github.com/romkatv/zsh-bench/tree/master/configs/zsh-syntax-highlighting),
[zsh-autosuggestions](https://github.com/romkatv/zsh-bench/tree/master/configs/zsh-autosuggestions)
and [powerlevel10k](https://github.com/romkatv/zsh-bench/tree/master/configs/powerlevel10k) as black
boxes. They cannot beat **diy++unsafe** on benchmarks.

**zim+** beats **diy++**—the safe version—on one metric. **zim** relies on
[unsafe optimizations](#cutting-corners) to gain this advantage: it compiles user rc files and
invokes `compinit` with `-C`. This is not a good choice in my opinion. The small speedup isn't
worth it.

All configs have very low *first prompt lag* thanks to powerlevel10k. The only exception is
**zplug**. **zplug** provides a nice API that plays well with [Instant Prompt](#instant-prompt). It
has one function to install plugins and another to load them. Installation of plugins can print
status messages and perform network I/O, so it should be done before the first prompt is printed.
Unfortunately, this function in **zplug** is rather slow, hence high *first prompt lag*. **zcomet**,
**zinit** and **zim** dodge this bullet by not providing this kind of API in the first place, so
these configs are [cutting corners](#cutting-corners). It's not that **zcomet**, **zinit** or
**zim** are acting recklessly here but rather their limitations don't allow me to cleanly use
*Instant Prompt*. When using these plugin managers you either have to give up *Instant Prompt* and
have *first prompt lag* over the threshold or cut corners and get subpar UX.

**zsh4humans** has lower *first command lag* and *input lag* than anything else. It achieves this by
implementing tight integration between the core shell features: prompt, syntax highlighting
and autosuggestions. You can enable *extra* plugins in **zsh4humans** but the core comes as a single
unit.

**zsh4humans** has *first prompt lag* 10% (5ms in absolute terms) higher than **diy++**. A lot of
features are packed into that chunk of time but this isn't the place to describe them. The resulting
*first prompt lag* is still just 28% of the threshold of perception, so I'm feeling pretty secure
that this latency won't be noticeable. Importantly, when users add extra initialization code to
their zsh startup files, it doesn't increase *first prompt lag*. It increases only
*first command lag*, which **zsh4humans** has at a lower value than other configs. Overall I'm
very happy with where **zsh4humans** stands.

If you don't care about `tmux`, you can mentally subtract
[its latencies](https://github.com/romkatv/zsh-bench/blob/master/doc/benchmarks.md) from any row in
the table. Given that **zplug** is only slightly over 100% on two metrics, subtracting **tmux** from
it brings all latencies in the table into the green or yellow territory. Everything is pretty fast!
Understanding the differences in functionality is what really matters for an informed choice. This
document is only about performance though, so I won't go into it.

### Deferred initialization

It's possible to defer some parts of zsh initialization and perform them when zsh has nothing else
to do. This can be done with [zinit turbo mode](https://github.com/zdharma/zinit#turbo-and-lucid) or
[zsh-defer](https://github.com/romkatv/zsh-defer). The latter is my project.

| config | tmux | compsys | syntax highlight | auto suggest | git prompt | first prompt lag | first cmd lag | cmd lag | input lag |
|-|-:|-:|-:|-:|-:|-:|-:|-:|-:|
| [zinit-turbo](https://github.com/romkatv/zsh-bench/tree/master/configs/zinit-turbo) | ✔️ | ✔️ | ❌ | ❌ | ✔️ | 18%<br>🟢 | 40%<br>🟢 | 27%<br>🟢 | 66%<br>🟡 |
| [zsh-defer](https://github.com/romkatv/zsh-bench/tree/master/configs/zsh-defer) | ✔️ | ✔️ | ❌ | ❌ | ✔️ | 18%<br>🟢 | 25%<br>🟢 | 27%<br>🟢 | 64%<br>🟡 |

In these configs the initialization of syntax highlighting and autosuggestions was deferred. When
deferring initialization of some features, you have to be prepared to use zsh without those features
for some time. The benchmark results indicate that the first command of the interactive shell
didn't have syntax highlighting or autosuggestions. This makes sense. Zsh was busy processing the
first command in Zsh Line Editor and hasn't reached the state of having nothing to do before the
command has started executing.

Initialization of the vast majority of features is unsafe to defer. Anything that modifies
environment variables, defines commands or changes the behavior of widgets shouldn't be deferred.

The only feature I know of whose initialization can be safely deferred is syntax highlighting.
Autosuggestions must be initialized *after* syntax highlighting, so you would have to defer both of
them or none. Unfortunately, deferring the initialization of autosuggestions is unsafe because it
changes the behavior of some keys, so you cannot use autosuggestions if you defer syntax
highlighting.

Deferred initialization runs within the context of Zsh Line Editor (zle). Some plugins don't expect
to be loaded from zle and may fail to properly initialize. Loading such plugins from zle requires
workarounds that often rely on the plugin's implementation details. This exposes the user to much
higher risk of breakage when updating plugins.

Deferred initialization can reduce only *first cmd lag*. If done properly, it has no effect on
other latencies. Given that there are many configs to choose from that are below the threshold on
*first cmd lag*, deferred initialization doesn't solve any real problems while adding quite a few of
its own.

So much for deferred initialization. Cannot recommend.

### How not to benchmark

If you search online for tips on how to benchmark zsh startup, you'll find the following command or
a variation thereof:

```zsh
time zsh -lic "exit"
```

For the sake of completeness, `zsh-bench` also measures this. This metric is shown as
*exit_time_ms* in the raw output. Let's look at a couple of raw benchmark results that pertain to
zsh startup speed.

| config | first prompt lag (ms) | first command lag (ms) | exit time (ms) |
|-|-:|-:|-:|
| [zim](https://github.com/romkatv/zsh-bench/tree/master/configs/zim) | 114 | 132 | 27 |
| [ohmyzsh+](https://github.com/romkatv/zsh-bench/tree/master/configs/ohmyzsh%2B) | 9 | 88 | 40 |

When using **zim**, `exit` finishes in just 27ms. That's fast! This shouldn't be surprising --
**zim** has been [optimized on this metric](
  https://github.com/zimfw/zimfw/wiki/Speed/a902e5597c9db37fb77716f0a4e0f9ad9220aca2). Yet, when
you open a terminal, you'll be looking at an empty screen for 114ms. And if you type the first
command immediately, it'll execute after 132ms. What exactly happens on the 27ms mark that counts
as "startup"?

Consider **ohmyzsh+** for comparison. With this config `exit` takes longer than with **zim** but zsh
starts faster: when you open a terminal, prompt appears virtually instantly and
the first command executes sooner.

**zim** isn't the only plugin manager optimizing for `exit` and presenting it as a
meaningful measure of performance. Many other plugin managers have been using this metric for lack
of alternatives. The widely held belief that **zinit** is the fastest plugin manager is based
on the timing of `exit`. Deferred initialization—pioneered by zinit turbo
mode—[may not be very useful in practice](#deferred-initialization) but it's extremely effective on
this metric. Unsurprisingly, **zinit** has been
[optimized for it](https://github.com/zdharma/pm-perf-test).

This doesn't mean developers have been engaging in conscious deception. It was easy to unknowingly
fall into the trap. The timing of `exit` is very close to *first prompt lag* and
*first command lag* in zsh configs from the older and simpler times. It *used to be* a proper
measure of zsh startup performance. At some point these latencies have diverged, the benchmark lost
its meaning, but the old habits remained.

**zsh4humans** clocks at 5ms on `exit` -- only 3ms above the baseline **no-rcs**. I'd be overjoyed
if I could claim that **zsh4humans** initializes that fast but there is no meaningful definition of
initialization for which this claim would be true.

The output of `time zsh -lic "exit"` tells you how long it takes to execute
`zsh -lic "exit"` and nothing else. If you aren't in the habit of running `zsh -lic "exit"`, there
is no reason for you to care one way or another about this number.

### Full benchmark data

- Date: 2021-10-14.
- OS: Ubuntu 20.04.
- CPU: AMD Ryzen Threadripper 3970x.
- Results: [raw](https://github.com/romkatv/zsh-bench/blob/master/doc/benchmarks.txt),
  [normalized](https://github.com/romkatv/zsh-bench/blob/master/doc/benchmarks.md).

### Conclusions

- [powerlevel10k](#powerlevel10k) is an effective tool for reducing startup and per-command lag.
- [diy++](https://github.com/romkatv/zsh-bench/blob/master/configs/diy%2B%2B/skel/.zshrc) is a
  performant and relatively simple base for a self-bootstrapping zsh config if you want to build one
  from scratch.
- Plugin managers cannot beat
  [diy++](https://github.com/romkatv/zsh-bench/blob/master/configs/diy%2B%2B/skel/.zshrc) on
  performance unless they [cut corners](#cutting-corners). A fast plugin manager is one that doesn't
  slow things down much. The value provided by a plugin manager is convenience, not speed.
- All plugin managers and frameworks have good performance when configured properly. This includes
  [ohmyzsh](https://github.com/romkatv/zsh-bench/blob/master/configs/ohmyzsh%2B/skel/.zshrc),
  despite a commonly held opinion that it's slow.
- From the "pure" plugin managers I've tested
  [zplug](https://github.com/romkatv/zsh-bench/blob/master/configs/zplug/skel/.zshrc) has the best
  API but it's also the slowest. The slowdown is small enough that it won't matter to most users.
- Not all plugin managers can cleanly use [Instant Prompt](#instant-prompt) -- the closest thing to
  a silver bullet in the battle for startup speed.
- [zsh4humans](https://github.com/romkatv/zsh4humans) is faster than anything else with comparable
  features. It beats even
  [diy++](https://github.com/romkatv/zsh-bench/blob/master/configs/diy%2B%2B/skel/.zshrc) on
  benchmarks thanks to tight integration of core features which cannot be replaced with third party
  plugins.
- Deferring zsh initialization with
  [zinit turbo mode](https://github.com/zdharma/zinit#turbo-and-lucid) or
  [zsh-defer](https://github.com/romkatv/zsh-defer) is not worth it.
- The output of `time zsh -lic "exit"` does not tell you anything about the performance of
  interactive zsh.

## License

[MIT](https://github.com/romkatv/zsh-bench/blob/master/LICENSE).

## FAQ

### Why is it important to benchmark my shell? Is it for enthusiasts?

It's not important to benchmark your shell. It is important for *me* to benchmark zsh plugins and
configs that I publish so that users of my code have fast shell. Shell users—or anyone for that
matter—prefer fast software over slow whether they are enthusiasts or not.
