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
  - [Responses](#responses)
  - [Debugging and validation](#debugging-and-validation)
- [License](#license)
- [FAQ](#faq)

## Summary

- `zsh-bench` measures user-visible latency of interactive zsh: *input lag*, *command lag*, etc. You
  can [use it to benchmark your own shell](#usage).
- `human-bench` measures human perception of latency when using interactive zsh. You can use it to
  check how it feels to use zsh with specific latencies or to test whether you can tell a
  difference between 5ms and 0ms lag.
- I've used `human-bench` to conduct a blind study on myself to find the maximum values of latencies
  that are indistinguishable from zero. For example, *command lag* below 10ms feels just like 0ms
  but anything above this value starts feeling sluggish.
- I've used these threshold values to normalize benchmark results to see what is fast and what is
  slow.
- Armed with this set of tools I've optimized two of my zsh projects:
  [powerlevel10k](https://github.com/romkatv/powerlevel10k) and
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

This requires zsh >= 5.8 and it must be your login shell.

If your zsh startup files start `tmux`, the benchmark may hang unless your `tmux` has [this fix](
  https://github.com/tmux/tmux/commit/9b1fdb291ee8e940311a51cf41f97b07930b4688#diff-2dec3ca953f8622e2bc9fe13a2eb464d057905e6f9313682665328c6b67910e6)
for [this bug](https://github.com/tmux/tmux/issues/2909).

If your zsh startup files enable history but don't set `histignorespace`, you might find random
commands in your history after running `zsh-bench`.

### Benchmark predefined zsh configs

```zsh
~/zsh-bench/zsh-bench --isolation docker -- <name> [name]..
```

This requires `docker`. Names of predefined zsh configs are directories under
[configs](https://github.com/romkatv/zsh-bench/tree/master/configs).

With `--isolation user` benchmarking is done as user `zsh-bench` on the host.

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
| **has git prompt** | git branch is displayed in prompt |

Latencies (in milliseconds):

| name | what time it measures | if too high |
|------|-----------------------|-------------|
| **first prompt lag (ms)** | from the start of the shell to the moment prompt appears on the screen | you get to stare at an empty screen for some time whenever you open a terminal |
| **first command lag (ms)** | from the start of the shell to the moment the first interactive command starts executing | you get to wait for the output of `ls` if you type it really fast after opening a terminal |
| **command lag (ms)** | from pressing <kbd>Enter</kbd> on an empty command line to the moment the next prompt appears; the same as [zsh-prompt-benchmark](https://github.com/romkatv/zsh-prompt-benchmark) (my project) | all commands appear to take longer to execute; the slowdown may happen after you press <kbd>Enter</kbd> and before the command starts executing, or after the command finishes executing and before the next prompt appears |
| **input lag (ms)** | from pressing a regular key to the moment the corresponding character appears on the command line; this test is performed when the current command line is already fairly long | keyboard input feels sluggish, as if you are working over an SSH connection with high latency |
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

I implemented `zsh-bench` in order to optimize [powerlevel10k](https://github.com/romkatv/powerlevel10k)
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
| [no-rcs](https://github.com/romkatv/zsh-bench/tree/master/configs/no-rcs) | ❌ | ❌ | ❌ | ❌ | ❌ | 3%<br>🟢 | 1%<br>🟢 | 1%<br>🟢 | 1%<br>🟢 |
| [tmux](https://github.com/romkatv/zsh-bench/tree/master/configs/tmux) | ✔️ | ❌ | ❌ | ❌ | ❌ | 9%<br>🟢 | 3%<br>🟢 | 1%<br>🟢 | 1%<br>🟢 |
| [compsys](https://github.com/romkatv/zsh-bench/tree/master/configs/compsys) | ❌ | ✔️ | ❌ | ❌ | ❌ | 45%<br>🟢 | 15%<br>🟢 | 1%<br>🟢 | 1%<br>🟢 |
| [zsh-syntax-highlighting](https://github.com/romkatv/zsh-bench/tree/master/configs/zsh-syntax-highlighting) | ❌ | ❌ | ✔️ | ❌ | ❌ | 25%<br>🟢 | 16%<br>🟢 | 6%<br>🟢 | 63%<br>🟡 |
| [zsh-autosuggestions](https://github.com/romkatv/zsh-bench/tree/master/configs/zsh-autosuggestions) | ❌ | ❌ | ❌ | ✔️ | ❌ | 36%<br>🟢 | 14%<br>🟢 | 107%<br>🟠 | 4%<br>🟢 |
| [git-branch](https://github.com/romkatv/zsh-bench/tree/master/configs/git-branch) | ❌ | ❌ | ❌ | ❌ | ✔️ | 35%<br>🟢 | 12%<br>🟢 | 57%<br>🟡 | 1%<br>🟢 |

**no-rcs** is zsh in its pure form, without any
[rc files](https://zsh.sourceforge.io/Intro/intro_3.html). It's really fast! Even if it was 10 times
slower, I wouldn't be able to tell a difference.

The rest of the entries here are the simplest configs capable of providing each capability. For
example, here's `.zshrc` from **zsh-autosuggestions**:

```zsh
source ~/zsh-autosuggestions/zsh-autosuggestions.zsh
```

Just one line. Plain and simple. `~/zsh-autosuggestions` is supposed to be created manually, outside
of zsh rc files. In the benchmark it's done by a `setup` script like this:

```zsh
git clone -q --depth=1 https://github.com/zsh-users/zsh-autosuggestions.git ~/zsh-autosuggestions
```

These basic building blocks are composable. We can easily create a config by combining any number
of them. Later we'll be doing just that. The latencies of a combination are the sums of latencies
of all its constituents. For example, *first prompt lag* of **tmux+compsys** is *first prompt lag*
of **tmux** plus *first prompt lag* of **compsys**. You can probably already see that adding
everything together will push some latencies over the threshold. Our goal is to avoid that while
still getting all the goodies. **git-branch** gives us *git prompt* for the price of 48% of our
*command lag* budget. Let's see if we can do better.

### Prompt

I've benchmarked several different git prompts.

| config | tmux | compsys | syntax highlight | auto suggest | git prompt | first prompt lag | first cmd lag | cmd lag | input lag |
|-|-:|-:|-:|-:|-:|-:|-:|-:|-:|
| [git-branch](https://github.com/romkatv/zsh-bench/tree/master/configs/git-branch) | ❌ | ❌ | ❌ | ❌ | ✔️ | 35%<br>🟢 | 12%<br>🟢 | 57%<br>🟡 | 1%<br>🟢 |
| [agnoster](https://github.com/romkatv/zsh-bench/tree/master/configs/agnoster) | ❌ | ❌ | ❌ | ❌ | ✔️ | 72%<br>🟡 | 24%<br>🟢 | 262%<br>🔴 | 1%<br>🟢 |
| [starship](https://github.com/romkatv/zsh-bench/tree/master/configs/starship) | ❌ | ❌ | ❌ | ❌ | ✔️ | 86%<br>🟡 | 29%<br>🟢 | 376%<br>🔴 | 1%<br>🟢 |
| [powerlevel10k](https://github.com/romkatv/zsh-bench/tree/master/configs/powerlevel10k) | ❌ | ❌ | ❌ | ❌ | ✔️ | 4%<br>🟢 | 15%<br>🟢 | 20%<br>🟢 | 1%<br>🟢 |

The git repo used by the benchmark has 1,000 directories and 10,000 files in it. Not too few,
not too many. All benchmarks ran with untracked cache enabled. Wall time of `git status` stood at
17ms.

**git-branch** only shows the name of the current branch and has the same latency regardless of the
repository size.

**agnoster** config uses the classic
[agnoster zsh theme](https://github.com/agnoster/agnoster-zsh-theme). It scans the whole repo to see
if there are untracked files, unstaged changes, etc. We can see that this causes lag on every
command pushing latency into the red. The lag is linear in the number of files and directories in
the git repo. You wouldn't want to use this theme in a truly large git repo with hundreds of
thousands or millions of files.

**starship** config uses the cross-shell [starship prompt](https://github.com/starship/starship).
It suffers from the same performance problems as agnoster plus some. Starship is implemented as an
external binary, so it has to pay the price of *at least one* additional fork+exec on every command
compared to native zsh prompts. One fork+exec cannot account for the high lag starship exhibits, so
what gives? Under the benchmark conditions starship
[clones](https://man7.org/linux/man-pages/man2/clone.2.html) 158 times! That's costly.

**powerlevel10k** config uses [powerlevel10k zsh theme](https://github.com/romkatv/powerlevel10k)
that I've developed. It scans the git repo just like agnoster and starship but it does not invoke
`git` to do that. Instead, it uses [gitstatus](https://github.com/romkatv/gitstatus) -- another of
my projects. This gives powerlevel10k a nice speedup on repositories large and small. In addition,
powerlevel10k doesn't block zsh prompt while gitstatus is scanning the repo, so *command lag* stays
constant even in giant repositories. Powerlevel10k has a few other interesting performance-related
properties that we'll [explore](#powerlevel10k) when we start building real zsh configs.

### Premade configs

Let's see what some of the popular premade zsh configs offer out of the box.

| config | tmux | compsys | syntax highlight | auto suggest | git prompt | first prompt lag | first cmd lag | cmd lag | input lag |
|-|-:|-:|-:|-:|-:|-:|-:|-:|-:|
| [prezto](https://github.com/romkatv/zsh-bench/tree/master/configs/prezto) | ❌ | ✔️ | ❌ | ❌ | ❌ | 116%<br>🟠 | 42%<br>🟢 | 15%<br>🟢 | 2%<br>🟢 |
| [ohmyzsh](https://github.com/romkatv/zsh-bench/tree/master/configs/ohmyzsh) | ❌ | ✔️ | ❌ | ❌ | ✔️ | 222%<br>🔴 | 76%<br>🟡 | 386%<br>🔴 | 2%<br>🟢 |
| [zim](https://github.com/romkatv/zsh-bench/tree/master/configs/zim) | ❌ | ✔️ | ✔️ | ✔️ | ✔️ | 127%<br>🟠 | 55%<br>🟡 | 201%<br>🔴 | 72%<br>🟡 |
| [zsh4humans](https://github.com/romkatv/zsh-bench/tree/master/configs/zsh4humans) | ✔️ | ✔️ | ✔️ | ✔️ | ✔️ | 20%<br>🟢 | 39%<br>🟢 | 30%<br>🟢 | 27%<br>🟢 |

The names of these configs match the respective public projects from which they were copied:
[ohmyzsh](https://github.com/ohmyzsh/ohmyzsh), [prezto](https://github.com/sorin-ionescu/prezto),
[zim](https://github.com/zimfw/zimfw) and [zsh4humans](https://github.com/romkatv/zsh4humans). The
latter is my project. All configs were used unmodified.

**prezto** is fast but doesn't provide much out of the box. No syntax highlighting, autosuggestions
or git prompt. Users who need these features—most do—should enable them explicitly.

**ohmyzsh** and **zim** by default use a theme with similar performance characteristics of
**agnoster**, so they have high *command lag* in larger git repositories. **zim** is the only config
among these that doesn't detect untracked files. This appears to have been a conscious decision by
**zim** developers for performance reasons. We can see that it helps: **zim** has approximately
half the *command lag* of **ohmyzsh**.

**zim** enables syntax highlight and autosuggestions by default, so it naturally has higher *input
lag* than projects that don't. Fast zsh startup is a major [explicit goal](
  https://github.com/zimfw/zimfw/wiki/Speed) of zim and we
can see that it beats **ohmyzsh** on *first prompt lag* and *first command lag*.

**zsh4humans** ticks all capability checkboxes and has all latencies comfortably in the green zone.
This shouldn't be surprising. In the game of optimization, measuring is half the work. I had access
to `zsh-bench`, so I was able to optimize zsh4humans to score well on it. Prior to creating
`zsh-bench` I knew that *input lag* and *first command lag* in zsh4humans were sometimes noticeable
but it was difficult to evaluate the effectiveness of potential optimizations when I not only
couldn't measure these latencies but didn't even have clear concepts for them.

Note that all these projects have extra features that aren't reflected in the capabilities shown in
the table. They all enable persistent history, define aliases, set shell options, etc.

### Do it yourself

Let's leave premade configs alone for some time and try to build a zsh config from scratch. Given
the availability of high-quality building blocks, this shouldn't be very difficult.

| config | tmux | compsys | syntax highlight | auto suggest | git prompt | first prompt lag | first cmd lag | cmd lag | input lag |
|-|-:|-:|-:|-:|-:|-:|-:|-:|-:|
| [diy](https://github.com/romkatv/zsh-bench/tree/master/configs/diy) | ✔️ | ✔️ | ✔️ | ✔️ | ✔️ | 135%<br>🟠 | 53%<br>🟡 | 170%<br>🟠 | 68%<br>🟡 |
| [diy+](https://github.com/romkatv/zsh-bench/tree/master/configs/diy%2B) | ✔️ | ✔️ | ✔️ | ✔️ | ✔️ | 10%<br>🟢 | 57%<br>🟡 | 26%<br>🟢 | 71%<br>🟡 |
| [diy++](https://github.com/romkatv/zsh-bench/tree/master/configs/diy%2B%2B) | ✔️ | ✔️ | ✔️ | ✔️ | ✔️ | 10%<br>🟢 | 45%<br>🟢 | 25%<br>🟢 | 66%<br>🟡 |

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
adds three such optimizations on top of **diy++** to reduce *first command lag* by 6%. I don't
recommend them.

| config | tmux | compsys | syntax highlight | auto suggest | git prompt | first prompt lag | first cmd lag | cmd lag | input lag |
|-|-:|-:|-:|-:|-:|-:|-:|-:|-:|
| [diy++unsafe](https://github.com/romkatv/zsh-bench/tree/master/configs/diy%2B%2Bunsafe) | ✔️ | ✔️ | ✔️ | ✔️ | ✔️ | 10%<br>🟢 | 38%<br>🟢 | 25%<br>🟢 | 66%<br>🟡 |

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
| [powerlevel10k](https://github.com/romkatv/zsh-bench/tree/master/configs/powerlevel10k) | ❌ | ❌ | ❌ | ❌ | ✔️ | 4%<br>🟢 | 15%<br>🟢 | 20%<br>🟢 | 1%<br>🟢 |
| [powerlevel10k-full](https://github.com/romkatv/zsh-bench/tree/master/configs/powerlevel10k-full) | ❌ | ❌ | ❌ | ❌ | ✔️ | 8%<br>🟢 | 31%<br>🟢 | 71%<br>🟡 | 8%<br>🟢 |

**powerlevel10k-full** has substantially higher *command lag* but it's still under 100%, meaning
that prompt is still indistinguishable from instantaneous. However, there is not much *command lag*
budget left for doing extra things on every command. So you would need to be careful with your zsh
config if you were to use powerlevel10k with everything turned on. In practice, no sane person would
enable *everything*. Here's a ridiculously overwrought prompt:

![Powerlevel10k Extravagant Style](
  https://raw.githubusercontent.com/romkatv/powerlevel10k-media/master/extravagant-style.png)

It has **18** segments. The full config enables **64**!

Notice that **powerlevel10k-full** also increases *input lag* by 7% (that's 1.4ms) compared to the
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
`.zshrc` prints to the terminal? The output will appear smack in the middle of what you perceive as
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
| [diy++](https://github.com/romkatv/zsh-bench/tree/master/configs/diy%2B%2B) | ✔️ | ✔️ | ✔️ | ✔️ | ✔️ | 10%<br>🟢 | 45%<br>🟢 | 25%<br>🟢 | 66%<br>🟡 |
| [diy++unsafe](https://github.com/romkatv/zsh-bench/tree/master/configs/diy%2B%2Bunsafe) | ✔️ | ✔️ | ✔️ | ✔️ | ✔️ | 10%<br>🟢 | 38%<br>🟢 | 25%<br>🟢 | 66%<br>🟡 |
| [zcomet](https://github.com/romkatv/zsh-bench/tree/master/configs/zcomet) | ✔️ | ✔️ | ✔️ | ✔️ | ✔️ | 10%<br>🟢 | 49%<br>🟢 | 27%<br>🟢 | 71%<br>🟡 |
| [zinit](https://github.com/romkatv/zsh-bench/tree/master/configs/zinit) | ✔️ | ✔️ | ✔️ | ✔️ | ✔️ | 10%<br>🟢 | 86%<br>🟡 | 27%<br>🟢 | 72%<br>🟡 |
| [zplug](https://github.com/romkatv/zsh-bench/tree/master/configs/zplug) | ✔️ | ✔️ | ✔️ | ✔️ | ✔️ | 119%<br>🟠 | 114%<br>🟠 | 27%<br>🟢 | 72%<br>🟡 |
| [ohmyzsh+](https://github.com/romkatv/zsh-bench/tree/master/configs/ohmyzsh%2B) | ✔️ | ✔️ | ✔️ | ✔️ | ✔️ | 10%<br>🟢 | 65%<br>🟡 | 32%<br>🟢 | 72%<br>🟡 |
| [prezto+](https://github.com/romkatv/zsh-bench/tree/master/configs/prezto%2B) | ✔️ | ✔️ | ✔️ | ✔️ | ✔️ | 10%<br>🟢 | 53%<br>🟡 | 39%<br>🟢 | 80%<br>🟡 |
| [zim+](https://github.com/romkatv/zsh-bench/tree/master/configs/zim%2B) | ✔️ | ✔️ | ✔️ | ✔️ | ✔️ | 11%<br>🟢 | 41%<br>🟢 | 27%<br>🟢 | 71%<br>🟡 |
| [zsh4humans](https://github.com/romkatv/zsh-bench/tree/master/configs/zsh4humans) | ✔️ | ✔️ | ✔️ | ✔️ | ✔️ | 20%<br>🟢 | 39%<br>🟢 | 30%<br>🟢 | 27%<br>🟢 |

**diy++** and **diy++unsafe** are listed here to serve as baseline for comparing latency.

The next three configs use "pure" plugin managers: [zcomet](https://github.com/agkozak/zcomet),
[zinit](https://github.com/zdharma-continuum/zinit) and [zplug](https://github.com/zplug/zplug).
These allow you to install and load plugins but don't configure zsh on their own in any way.

Configs **ohmyzsh+**, **prezto+** and **zim+** are based on the respective standard configs. I've
enabled only the plugins that are required to tick off all capabilities and disabled the rest.

**zsh4humans** can install and load arbitrary plugins but the default config already enables
everything we care about. So I'm benchmarking the stock config with no changes here.

All configs in this list except for **zsh4humans** treat [zsh-syntax-highlighting](
  https://github.com/romkatv/zsh-bench/tree/master/configs/zsh-syntax-highlighting),
[zsh-autosuggestions](https://github.com/romkatv/zsh-bench/tree/master/configs/zsh-autosuggestions)
and [powerlevel10k](https://github.com/romkatv/zsh-bench/tree/master/configs/powerlevel10k) as black
boxes. They cannot beat **diy++unsafe** on benchmarks.

**zim+** beats **diy++**—the safe version—on one metric. **zim** relies on an
[unsafe optimization](#cutting-corners) to gain this advantage: it invokes `compinit` with `-C`.
This is not a good choice in my opinion. The small speedup isn't worth it.

**zim** isn't the only project on this list that trades usability for performance by invoking
`compinit` with `-C`. **zplug**, **ohmyzsh** and **prezto** do that too. **zsh4humans** is the only
project that goes the opposite way -- it performs *more* checks than the regular `compinit` in order
to improve usability of the completion system. For example, if you add a completion function to
an existing file with a `#compdef` directive, none of the configs except for **zsh4humans** will
pick up this change until you manually delete `.zcompdump`. Restarting zsh or even rebooting the
machine won't help. **zsh4humans** manages to achieve *first command lag* lower than any other
config despite the additional quality of life improvements. This shows that cutting corners isn't
necessary for achieving low latency goals.

All configs have very low *first prompt lag* thanks to powerlevel10k. The only exception is
**zplug**. **zplug** provides a nice API that plays well with [Instant Prompt](#instant-prompt). It
has one function to install plugins and another to load them. Installation of plugins can print
status messages and perform network I/O, so it should be done before the first prompt is printed.
Unfortunately, this function in **zplug** is rather slow, hence high *first prompt lag*. **zcomet**,
and **zinit** dodge this bullet by not providing this kind of API in the first place, so
these configs are [cutting corners](#cutting-corners). It's not that **zcomet** and **zinit** are
acting recklessly here but rather their limitations don't allow me to cleanly use *Instant Prompt*.
When using these plugin managers you either have to give up *Instant Prompt* and have
*first prompt lag* over the threshold or cut corners and get subpar UX.

**zsh4humans** has lower *first command lag* and *input lag* than anything else. It achieves this by
implementing tight integration between the core shell features: prompt, syntax highlighting
and autosuggestions. You can enable *extra* plugins in **zsh4humans** but the core comes as a single
unit.

**zsh4humans** has *first prompt lag* 10% (5.2ms in absolute terms) higher than **diy++**. A lot of
features are packed into that chunk of time but this isn't the place to describe them. The resulting
*first prompt lag* is still just 20% of the threshold of perception, so I'm feeling pretty secure
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
to do. This can be done with [zinit turbo mode](
  https://github.com/zdharma-continuum/zinit#turbo-and-lucid) or [zsh-defer](
    https://github.com/romkatv/zsh-defer). The latter is my project.

| config | tmux | compsys | syntax highlight | auto suggest | git prompt | first prompt lag | first cmd lag | cmd lag | input lag |
|-|-:|-:|-:|-:|-:|-:|-:|-:|-:|
| [zinit-turbo](https://github.com/romkatv/zsh-bench/tree/master/configs/zinit-turbo) | ✔️ | ✔️ | ❌ | ❌ | ✔️ | 10%<br>🟢 | 41%<br>🟢 | 25%<br>🟢 | 63%<br>🟡 |
| [zsh-defer](https://github.com/romkatv/zsh-bench/tree/master/configs/zsh-defer) | ✔️ | ✔️ | ❌ | ❌ | ✔️ | 10%<br>🟢 | 24%<br>🟢 | 29%<br>🟢 | 68%<br>🟡 |

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
other latencies. Given that there are many configs to choose from that are below the perception
threshold on *first cmd lag*, deferred initialization doesn't solve any real problems while adding
quite a few of its own.

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
| [agnoster](https://github.com/romkatv/zsh-bench/tree/master/configs/agnoster) | 36 | 37 | 3 |
| [powerlevel10k](https://github.com/romkatv/zsh-bench/tree/master/configs/powerlevel10k) | 2 | 23 | 8 |

When using **agnoster**, `exit` finishes in just 3ms. Yet, when you open a terminal, you'll be
looking at an empty screen for 37ms. What exactly happens on the 3ms mark that counts as "startup"?

Consider **powerlevel10k** for comparison. With this config `exit` takes longer than with
**agnoster** but zsh starts faster: when you open a terminal, prompt appears virtually instantly and
the first command executes sooner.

Many zsh plugin managers have been optimized for fast `exit` and are presenting it as a meaningful
measure of performance. The widely held belief that **zinit** is the fastest plugin manager is based
on the timing of `exit`. Deferred initialization—pioneered by zinit turbo
mode—[may not be very useful in practice](#deferred-initialization) but it's extremely effective on
this metric. Unsurprisingly, **zinit** has been [optimized for it](
  https://web.archive.org/web/20201122095227/https://github.com/zdharma/pm-perf-test).

This doesn't mean developers have been engaging in conscious deception. It was easy to unknowingly
fall into the trap. The timing of `exit` is very close to *first prompt lag* and
*first command lag* in zsh configs from the older and simpler times. It *used to be* a proper
measure of zsh startup performance. At some point these latencies have diverged, the benchmark lost
its meaning, but the old habits remained.

**zsh4humans** clocks at 7ms on `exit`. I'd be overjoyed if I could claim that **zsh4humans**
initializes that fast but there is no meaningful definition of initialization for which this claim
is true.

The output of `time zsh -lic "exit"` tells you how long it takes to execute
`zsh -lic "exit"` and nothing else. If you aren't in the habit of running `zsh -lic "exit"`, there
is no reason for you to care one way or another about this number.

Since the release of zsh-bench several projects have switched from targeting `exit` to meaningful
performance metrics. The ones I know of are **zcomet**, **zim** and **antidote**. There is hope that
this trend will continue.

### Full benchmark data

- Fast desktop machine (all benchmark results inlined in this document are from this run):
  - Date: 2022-03-13.
  - OS: Ubuntu 21.10.
  - CPU: AMD Ryzen Threadripper 3970x.
  - Storage: NVMe M.2.
  - Results: [raw](https://github.com/romkatv/zsh-bench/blob/master/doc/linux-desktop.txt),
    [normalized](https://github.com/romkatv/zsh-bench/blob/master/doc/linux-desktop.md).
- MacBook Air (M1, 2020):
  - Date: 2021-11-09.
  - OS: macOS Monterey.
  - Chip: Apple M1.
  - Storage: SSD.
  - Power: battery (not plugged into the power outlet).
  - Results: [raw](https://github.com/romkatv/zsh-bench/blob/master/doc/macos-laptop.txt),
    [normalized](https://github.com/romkatv/zsh-bench/blob/master/doc/macos-laptop.md).
- Raspberry Pi 4 Model B:
  - Date: 2021-11-09.
  - OS: Raspbian Buster (32 bit).
  - CPU: ARM Cortex-A72.
  - Storage: microSD.
  - Results: [raw](https://github.com/romkatv/zsh-bench/blob/master/doc/linux-raspberrypi.txt),
    [normalized](https://github.com/romkatv/zsh-bench/blob/master/doc/linux-raspberrypi.md).

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
  [zinit turbo mode](https://github.com/zdharma-continuum/zinit#turbo-and-lucid) or
  [zsh-defer](https://github.com/romkatv/zsh-defer) is not worth it.
- The output of `time zsh -lic "exit"` does not tell you anything about the performance of
  interactive zsh.

### Responses

This section lists public responses from the developers of analyzed projects.

#### zcomet

From [README.md](
  https://github.com/agkozak/zcomet/blob/52f2eaa7e7c09fb32e31e10ce1d45cb719065be4/README.md#news):

> - October 13, 2021
>     + I have adopted [@romkatv](https://github.com/romkatv)'s
>       [zsh-bench](https://github.com/romkatv/zsh-bench) benchmarks as a standard for measuring
>       performance.
>     + `zcomet` no longer `zcompiles` rc files, and the default behavior of `zcomet compinit` is
>       merely to run `compinit` while specifying a sensibly named cache file (again, props to
>       **@romkatv** for suggesting these changes).

Similarly on [reddit](
  https://www.reddit.com/r/zsh/comments/q5e2du/ann_zshbench_benchmark_for_interactive_zsh/hgjnryv/):

> I've taken your advice: `zcomet` no longer compiles rc files, and `zcomet compinit` is no longer
> `compinit -C` by default.
>
> Next I'll look into the issue of compatibility with your *Instant Prompt*.

#### zim

This [summary](https://github.com/romkatv/zsh-bench/issues/5#issuecomment-1029519185):

> Thanks to [@romkatv](https://github.com/romkatv)'s input and to his thoughts in
> [zsh-bench](https://github.com/romkatv/zsh-bench), this is what we've improved in
> [Zim](https://github.com/zimfw/zimfw):
>
> * We changed [our benchmarks](https://github.com/zimfw/zsh-framework-benchmark) to measure the
>   time to the first prompt appearance (instead of the time to run `exit`). We're using a different
>   tool ([expect](https://linux.die.net/man/1/expect)) than zsh-bench
>   ([script](https://linux.die.net/man/1/script)) to measure that time, and
>   [@romkatv](https://github.com/romkatv) helped us make use the times between our different
>   approaches match.
> * We don't compile Zsh startup scripts, and we don't compile any scripts in the background
>   anymore. The former is considered
>   ["cutting corners"](https://github.com/romkatv/zsh-bench/blob/3ed27aa21c13cba81b0c0065a54df5cfd50ef79c/README.md#cutting-corners)
>   in zsh-bench, and the latter
>   [unreliable](https://github.com/romkatv/zsh-bench/pull/11#issuecomment-994979683). In fact, now
>   Zim does not run anything in the background during your shell experience. We've added a
>   `check-dumpfile` action to `zimfw`. It runs after updating files (in the build, install and
>   update actions), and checks if a new completion configuration needs to be dumped. It's intended
>   to be used with `compinit -C` to guarantee the same checks that `compinit` does, since using
>   `compinit -C` alone is also considered
>   ["cutting corners"](https://github.com/romkatv/zsh-bench/blob/3ed27aa21c13cba81b0c0065a54df5cfd50ef79c/README.md#cutting-corners)
>   in zsh-bench.
> * We've also updated our templates to set `ZSH_AUTOSUGGEST_MANUAL_REBIND=1` and source the
>   zsh-users/zsh-autosuggestions module last.

### Debugging and validation

Several tools are included in zsh-bench to aid in debugging and validation of benchmark results.

Perform one iteration of login shell benchmark and retain temporary benchmark data:

```zsh
~/zsh-bench/zsh-bench --iters 1 --scratch-dir /tmp/zsh-bench
```

Replay the screen of the TTY that `zsh-bench` was acting on during benchmarking:

```zsh
~/zsh-bench/dbg/replay --scratch-dir /tmp/zsh-bench
```

Replay at 10% speed and at most 1s delay between TTY updates:

```zsh
~/zsh-bench/dbg/replay --scratch-dir /tmp/zsh-bench --delay-multiplier 10 --max-delay-ms 1000
```

Don't resize your terminal after running `zsh-bench` so that everything replays correctly.

You'll see that at first `zsh-bench` issues a short command that sources a script. This command gets
sent to the TTY right away without waiting for first prompt. The sourced file prints, and the result
of that printing signifies execution of the first command.

Then `zsh-bench` starts measuring input latency. It prints a fairly long command composed of a bunch
of escaped `abc` tokens, types one more character and waits for that character to be processed by
[zle](https://zsh.sourceforge.io/Doc/Release/Zsh-Line-Editor.html). This is performed several times
and then the command line is cleared without execution.

Then `zsh-bench` measures command lag by spamming <kbd>Enter</kbd> and seeing how many prompts it
would get.

Print a TAB-separated table of timestamped raw writes to the TTY:

```zsh
~/zsh-bench/dbg/timeline --scratch-dir /tmp/zsh-bench
```

See what happened at the specific timestamp:

```zsh
~/zsh-bench/dbg/replay --scratch-dir /tmp/zsh-bench --pause-at-ms 10.149
```

The last argument is a timestamp in milliseconds. The replay will pause right before and right after
it. If you pass the value of `first_prompt_lag_ms` or `first_command_lag_ms` reported by `zsh-bench`
as the timestamp, you'll see what `zsh-bench` considered *first prompt* and the output of
*first command* respectively. If `zsh-bench` did its job correctly, the screen before
`first_prompt_lag_ms` shouldn't have prompt but afterwards it should. Similarly, the screen before
`first_command_lag_ms` shouldn't have `ZB*-msg` but afterwards it should (the first command prints
`ZB*-msg` where `*` is a random number). Capability `has_git_prompt` should be set if and only if
`ZB*-branch` appears before `ZB*-msg`. In other words, `has_git_prompt` signifies that the first
prompt shows git branch.

## License

[MIT](https://github.com/romkatv/zsh-bench/blob/master/LICENSE).

## FAQ

### Why is it important to benchmark my shell? Is it for enthusiasts?

It's not important to benchmark your shell. It is important for *me* to benchmark zsh plugins and
configs that I publish so that users of my code have fast shell. Shell users—or anyone for that
matter—prefer fast software over slow whether they are enthusiasts or not.
