---
name: notebook-summary
description: Summarise a Jupyter notebook section by section (what matters, what to skip), explain why it matters and how it is used in the real world, then append a 5-10 question MCQ quiz to the end of the notebook. Use when the user asks to summarise, overview, or quiz them on a .ipynb file.
---

# Notebook Summary

Give the user a short, plain overview of a Jupyter notebook so they know where to focus, then test their understanding with an MCQ quiz appended to the notebook.

## Inputs

- The notebook path. If the user did not give one, list the `.ipynb` files in the working directory and ask which one.

## Step 1: Read the notebook

- Read the whole notebook, markdown and code cells, including any saved outputs.
- Split it into sections using the markdown headings. If there are no headings, group cells into logical blocks (e.g. data loading, preprocessing, model, training, evaluation).
- Do not run any cells.

## Step 2: Write the overview (in chat)

Keep everything short and plain. Plain explanation first, technical explanation second. No long paragraphs.

### 2a. Section table

| # | Section | Main idea (plain terms) | What to look out for | Priority |
|---|---------|------------------------|----------------------|----------|

- **Main idea**: one sentence, no jargon.
- **What to look out for**: the key line, concept, gotcha, or result in that section.
- **Priority**: one of
  - **Must read**: core concept of the notebook, needed to understand the rest
  - **Skim**: useful context, worth a quick look
  - **Can skip**: setup, imports, boilerplate, repeated plotting, or content already known

### 2b. Most important sections

A short list of the 2-4 "Must read" sections, each with:
- **In plain terms**: 1-2 sentences.
- **Technically**: 2-4 sentences covering the actual method, maths, or code mechanism.

### 2c. Why this notebook matters

- **In the learning journey**: what this builds on and what it sets up next (2-3 sentences).
- **Real-world use**: 2-3 concrete scenarios where this technique is used in industry.
- **Benefits**: 2-4 bullet points on what this approach gives you (accuracy, speed, interpretability, scale, etc.) and, briefly, its main limitation.

## Step 3: Write the MCQ quiz

### Number of questions

Decide based on how much theory the notebook covers:
- Short notebook or one core concept: 5 questions
- Medium notebook: 6-8 questions
- Long notebook or many concepts: 9-10 questions
- Never fewer than 5 or more than 10.

### Question rules

- Test **theory and understanding**: why a method works, when to use it, what a parameter controls, how to interpret a result, what goes wrong if a step is skipped.
- Do not test trivia such as variable names, cell numbers, or exact printed values.
- Prioritise "Must read" sections; cover each major concept at least once.
- Exactly 3 options (A, B, C), exactly 1 correct answer.
- Wrong options must be plausible, not obviously silly.
- Spread the correct answers across A, B and C.
- Each answer includes a 1-2 sentence explanation of why it is right and why the most tempting wrong option is wrong.

## Step 4: Append the quiz to the end of the notebook

- If the notebook already has a quiz section from a previous run (a markdown cell starting with `## Check Your Understanding`), replace those cells instead of adding a second quiz.
- Insert new **markdown cells** after the last cell, using the NotebookEdit tool in insert mode. If that fails, edit the `.ipynb` JSON with a short Python script that only appends to the `cells` list.
- Do not modify, reorder, or delete any existing cells, and do not clear outputs.

Cell 1 (header):

```markdown
## Check Your Understanding

N questions on the theory covered in this notebook. Answer each one before opening the answer.
```

One cell per question:

```markdown
### Q1. <question>

- **A.** <option>
- **B.** <option>
- **C.** <option>

<details>
<summary>Show answer</summary>

**Answer: B**

<explanation>

</details>
```

## Step 5: Finish

In chat, after the overview, add one line saying how many questions were added to the end of the notebook. Do not repeat the questions or answers in chat.
