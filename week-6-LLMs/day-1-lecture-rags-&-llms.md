# Retrieval Augmented Generation & LLMs

**DE.IO Description:**

In this lecture, Zach dives into the powerful implications of LLMs and RAG techniques for engineers, emphasizing the importance of adapting to these changes. He discusses the differences between fine-tuning and RAG, and how they can be leveraged together for better outcomes. He also highlights the significance of creating effective prompts for generating SQL with LLMs.

## Main Topics for the lecture

- How will LLMs impact data engineering?
- How will data engineering impact LLMs?
- What is RAG and why should data engineers care?
- How do you set up a RAG model?
- RAG vs Fine-tuning models

![Lecture 1 1](https://github.com/marian-z/data-expert-io-bootcamp-2025/raw/main/week-6-LLMs/images/lecture-1-1.png)

## How will LLMs impact data engineering?

- If you think about the skills which are necessary for data engineering you can think of them in 2 continuums based on the chart above:
  - If you look at the the chart from top to bottom then it would be the continuum from **More Technical** to **More Soft Skills**
  - Left to right: **Tactical** to **Strategic skills**
- The bottom right corner would be the safest space for you as a Data Engineer as that way you will focus more on people and soft skills and strategic vision
- There are a few things here which are more of a reason to celebrate as opposed to being all doom and gloom about the future of our field
- One of the more optimistic things here would be the ability to possibly use AI to Fix a broken pipeline, generate fake datasets for testing or writing analytical SQL queries if you already have thought out the process which means you know the input and expected output schemas and the analytical pattern that you want/need to apply for the pipeline
- LLMs will be able to be able to deprecate conceptual data modeling when stakeholders will be able to say what they want (which is literally never going to happen based on every data engineers experience)
- It is most likely never going to happen because in order to do that you have to take a foggy request from a stakeholder and distill it into a valid use case, which is a process that requires a lot of conversation, persuasion, negotiation, push-back, collaboration, brainstorming etc.
- Your job is safer the more you interact with people and the less you interact with code

## How will DE impact LLMs?

- LLMs are just a Machine Learning Models, a set of probabilities that do things that you can make more accurate, faster and better:
- Faster, more automated decisions
  - i.e. grading in the bootcamp
- Higher quality fine tuning
  - Generating more high quality datasets for fine tuning
- More relevant RAG queries
- Building evaluation criteria of models
  - You need to build a set of prompts, and questions and actions (given this prompt with this context this action should be taken)
  - You can think of this as a kind of CI/CD for models
  - **This blurs the line between data engineering and MLOPS**

## What is RAG and why should DEs care?

- RAG allows you to supplement LLMs with your company data
  - You use your company’s data as the context for LLM
- RAG needs to build a context that is injected into a prompt
- This context can be built in a few different ways

## How to setup RAG

![Lecture 1 2](https://github.com/marian-z/data-expert-io-bootcamp-2025/raw/main/week-6-LLMs/images/lecture-1-2.png)

- Every single piece of this system can be fiddled with (how you search for context, how the prompt is augmented etc.)
- Context is usually provided/fed into LLM via vector databases
- Vector Search, Keyword Search and Graph Search are most used ways to search and augment your prompts
- RAG is very easy to set up, but rather difficult to put into production and a space where you can trust it

![Lecture 1 3](https://github.com/marian-z/data-expert-io-bootcamp-2025/raw/main/week-6-LLMs/images/lecture-1-3.png)

## RAG vs Fine-Tuning Model

![Lecture 1 4](https://github.com/marian-z/data-expert-io-bootcamp-2025/raw/main/week-6-LLMs/images/lecture-1-4.png)

- This approach allows you to build faster systems as you can see that there is no retrieval and augmentation step

|     | **Change Cadence** | **Cost** | **Flexibility** |
| --- | --- | --- | --- |
| **RAG** | Extremely fast | RAG has many more input tokens which is pricey | You can do RAG on top of any model you choose. Even switching models on the fly! |
| **Fine Tuning** | More slowly (training ML models is a slow process) | Fine tuned models that are tuned infrequently are much cheaper! | You have to pick a model and fine tune it if you’re going with fine tuning |
