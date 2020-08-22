# Contribution guide

Thank you for your input and support! Here are some guidelines to follow when contributing.

## 🐛 Bug reports

- Explain the troubleshooting steps you've already tried
- Use GitHub-flavored Markdown, especially code fences <code>```</code> to format logs
- Include reproduction steps or code for a failing test case if you can

## ✨ Feature requests

Ideas for new bundleup features are appreciated!

- Show examples of how the feature would work
- Explain your motivation for requesting the feature
- Would it be useful for the majority of bundleup users?
- Is it a breaking change?

## ⤴️ Pull requests

> Protip: If you have a big change in mind, it is a good idea to open an issue first to propose the idea and get some initial feedback.

### Working on code

- Run `bin/setup` to install dependencies
- `bin/console` opens an irb console if you need a REPL to try things out
- `bundle exec bundleup` will run your working copy of bundleup
- `rake install` will install your working copy of bundleup globally (so you can test it in other projects)
- Make sure to run `rake` to run all tests and RuboCop checks prior to opening a PR

### PR guidelines

- Give the PR a concise and descriptive title that completes this sentence: _If this PR is merged, it will [TITLE]_
- If the PR fixes an open issue, link to the issue in the description
- Provide a description that ideally answers these questions:
  - Why is this change needed? What problem(s) does it solve?
  - Were there alternative solutions that you considered?
  - How has it been tested?
  - Is it a breaking change?
  - Does the documentation need to be updated?
