# Intro to Harness Engineering

## What is a Harness?

In AI-assisted development, a **harness** is a tool that creates a feedback loop between a coding agent and the real-world output of its code. Instead of telling an agent what to fix, you build a system that lets it **see**, **evaluate**, and **iterate** on its own.

## The Assignment

You are given a lab monitoring dashboard (`index.html` + `styles.css`). It has visual issues.

Your job: **build a screenshot tool** that a coding agent can use to see the rendered page, then let the agent fix the issues by itself.

### Rules

1. **Build a harness script** that:
   - Renders `index.html` to a visible page
   - Captures a screenshot of the result
   - Provides that screenshot to a coding agent for analysis

2. **Do NOT use Playwright, Puppeteer, Selenium, or any browser automation framework.** Figure out another way to capture a screenshot of rendered HTML. This is the core engineering challenge. **VERIFY** the model actually uses your screenshot script, you may need to disable plugins you have enabled that provide this functionality.

3. **Do NOT tell the agent what is wrong.** Use `prompt.txt` as the sole instruction to your coding agent. No additional guidance about specific issues. You will need to make a small edit to `prompt.txt`.

4. The agent should be able to loop: screenshot → analyze → edit → screenshot again to verify.

### What You'll Turn In

- Your harness script
- The agent's final corrected version of the dashboard

### How You'll Turn in

- Make a pull request on this repo with your changes.

### Hints

- Your harness is the agent's **eyes**. The better it sees, the better it performs.
- A good harness requires zero human guidance beyond the initial prompt.
- This is an AI-native project, I do expect you're using AI to complete these assignments. A goal of this capstone is to push tools to a real production project, do not rely on vibes.
- This assignment should not take more than an hour, if it does please contact me.
