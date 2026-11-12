---
date: "2026-11-12T09:00:00Z"
tags: programming
title: Submitting a patch to GNU sed
---


I'm working on a [long option parser](https://git.sr.ht/~miccah/hare-longopt)
for [Hare](https://harelang.org/) and decided to use `sed` as an example
(because Hare stdlib's `getopt` has a `sed` example). This is `sed`'s man
page:

![sed man page](/assets/man-sed/1.png)

Zoom in..

![sed man page](/assets/man-sed/2.png)

Enhance..

![sed man page](/assets/man-sed/3.png)

Huh, what does `-V` do?? It's not described in the man page. Let's try it.

```bash
» sed -V
sed: option requires an argument -- 'V'
```

Okay.. giving it a `wut` argument resulted in no error message and just the
usage text. So I found the [GNU sed project page](https://www.gnu.org/software/sed/),
cloned the source, and found it really wasn't doing anything. In fact, `-V`
used to be a version flag but it was removed in version 4.1 (released in
2004!).

So I made and submitted a patch for it! This is why I love open source
software.

{{< details "**the patch itself**" "open" >}}

```diff
diff --git a/NEWS b/NEWS
index b5c768e..927743a 100644
--- a/NEWS
+++ b/NEWS
@@ -38,6 +38,10 @@ GNU sed NEWS                                    -*- outline -*-
   expression '.' cannot match an invalid multibyte sequence.
   [bug introduced in sed 4.2]
 
+  The undocumented '-V' option has been removed. sed now flags it as an
+  invalid option and no longer consumes a following argument.
+  [bug introduced in sed 4.1]
+
 
 * Noteworthy changes in release 4.10 (2026-04-21) [stable]
 
diff --git a/doc/sed.x b/doc/sed.x
index c1b1fcf..928f644 100644
--- a/doc/sed.x
+++ b/doc/sed.x
@@ -2,7 +2,7 @@
 sed \- stream editor for filtering and transforming text
 [SYNOPSIS]
 .nf
-sed [-V] [--version] [--help] [-n] [--quiet] [--silent]
+sed [--version] [--help] [-n] [--quiet] [--silent]
     [-l N] [--line-length=N] [-u] [--unbuffered]
     [-E] [-r] [--regexp-extended]
     [-e script] [--expression=script]
diff --git a/sed/sed.c b/sed/sed.c
index 3155dab..661edc2 100644
--- a/sed/sed.c
+++ b/sed/sed.c
@@ -189,7 +189,7 @@ specified, then the standard input is read.\n\
 int
 main (int argc, char **argv)
 {
-#define SHORTOPTS "bsnrzuEe:f:l:i::V:"
+#define SHORTOPTS "bsnrzuEe:f:l:i::"
 
   enum { SANDBOX_OPTION = CHAR_MAX+1,
          DEBUG_OPTION
```

The change itself is pretty simple but has been part of GNU sed for over 22
years! I also learned something new about `optstring` (via `man 3 getopt`). A
character followed by a single `:` is a required argument, but if it's followed
by a double `::`, it is an optional argument.

Also! `W;` makes `-W foo` equivalent to `--foo`! That's wild!

{{< /details >}}


I think most modern-day programmers are familiar with submitting changes to
source forges like GitHub or GitLab, but GNU is a *pretty* old project and it's
not obvious how to do that. You actually have to send the change in via
*email*!

You could do that by generating a patch file via `git format-patch` and pasting
the text into a standard email client, but the *cool* way is to send the email
directly from `git`. That's right, `git` has builtin support for emailing
patches. [Here](https://git-send-email.io/) is a beginner-friendly walk-through
of how to set that up. I also learned you can configure git to use a
[credential helper](https://git-scm.com/docs/gitcredentials) to automatically
get the password from secure storage (like a password manager), which is what I
did too.

With all that done, I was ready to submit the patch:

```bash
» git send-email --to="bug-sed@gnu.org" HEAD^
```

```
OK. Log says:
Server: smtppro.zoho.com
MAIL FROM:<dev@miccah.io>
RCPT TO:<bug-sed@gnu.org>
RCPT TO:<dev@miccah.io>
From: Miccah <dev@miccah.io>
To: bug-sed@gnu.org
Cc: Miccah <dev@miccah.io>
Subject: [PATCH] sed: remove -V short option
Date: Wed, 11 Nov 2026 21:52:18 -0800
Message-ID: <20261112055218.54455-1-dev@miccah.io>
X-Mailer: git-send-email 2.54.0
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

Result: 250
```

🎉
