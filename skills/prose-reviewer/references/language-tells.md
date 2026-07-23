# AI-writing tells: language and grammar
> Derived from [Wikipedia:Signs of AI writing](https://en.wikipedia.org/wiki/Wikipedia:Signs_of_AI_writing) (CC BY-SA 4.0), retrieved 2026-07-23; wiki links, citations, and page furniture stripped for reviewer-agent use. The full vendored copy with provenance is `signs-of-ai-writing.md`.

Patterns in *word choice and sentence structure* — AI vocabulary, negative parallelisms, rule-of-three padding, elegant variation.

AI-generated text displays consistent patterns in syntax, word choice, and sentence construction that human writing does not display to nearly the same degree. Conversely, it often struggles to match some syntactic and linguistic patterns characteristic of human writing. Some LLMs deviate more from human writing than others; for example, GPT-4o, the language model used by ChatGPT from May 2024 to August 2025, produces output with more variation from human writing than other contemporaneous language models. Since these are linguistic patterns, they occur consistently regardless of the subject matter, which often gives AI-generated text an identifiable "voice".

### High density of "AI vocabulary" words

> Words to watch: ***Additionally* (especially beginning a sentence), *align with*, *boasts* (meaning "has"), *bolstered*, *crucial*, *delve*, *emphasizing*, *enduring*, *enhance*, *fostering*, *garner*, *highlight* (as a verb), *interplay*, *intricate/intricacies*, *key* (as an adjective),[*citation needed*] *landscape* (as an abstract noun), *meticulous/meticulously*, *pivotal*, *robust*, *showcase*, *tapestry* (as an abstract noun), *testament*, *underscore* (as a verb), *valuable*, *vibrant***

Many studies have demonstrated that LLMs overuse specific words. These words started appearing far more frequently in text produced after 2022, when LLM chatbots became widely accessible. They often co-occur in LLM output: where there is one, there are likely others. While most of these studies have analyzed scientific abstracts or fiction, "AI vocabulary" words are also ubiquitous in LLM-based encyclopedias, such as Grokipedia, and in AI-generated Wikipedia text. One or two of these words appearing in an edit may be coincidental, but an edit (post-2022) introducing lots of them, lots of times, is one of the strongest tells for AI use.

The words that LLMs overuse have changed over time. For instance, the word *delve* was famously overused by ChatGPT in 2023 and early 2024, but became less frequent later in 2024, then dropped off sharply in 2025. Below is a breakdown of which words frequently recur together during which LLM "era". While these are not hard cutoffs, they should give you a rough idea of how "earlier" vs "later" LLM output reads.

* **2023 to mid-2024** (GPT-4): *Additionally*, *boasts*, *bolstered*, *crucial*, *delve*, *emphasizing*, *enduring*, *garner*, *intricate/intricacies*, *interplay*, *key*, *landscape*, *meticulous/meticulously*, *pivotal*, *underscore*, *tapestry*, *testament*, *valuable*, *vibrant*
* **Mid-2024 to mid-2025** (GPT-4o): *align with*, *bolstered*, *crucial*, *emphasizing*, *enhance*, *enduring*, *fostering*, *highlighting*, *pivotal*, *showcasing*, *underscore*, *vibrant*
* **Mid-2025 and on** (GPT-5): *emphasizing*, *enhance*, *highlighting*, *showcasing* (plus words associated with "Undue emphasis on notability, attribution, and media coverage")

The distribution of "AI vocabulary" is also somewhat different depending on the chatbot or LLM used. Grok output is particularly idiosyncratic: it overuses superficially "scientific" words like *causal*, *empirical*, *correlate*, and continues to overuse *underscore* as of 2026.

This section is to be taken as literally as possible: a word being overused by AI does *not* imply that its synonyms are also overused. Also, keep context in mind. For example, while the figurative use of "underscore" is ubiquitous in earlier AI text, the word can also refer to a literal underline mark or to incidental music.

**Examples**

> The inscriptions also offer valuable insights into the construction of the mosque. They record the names of the key craftsmen involved, including Mason Ahmad b. Muhammad, known as Haddad (the smith or iron-worker), and Hjajji Muhammad, the tile-cutter from Tabriz. These names highlight the collaborative nature of mosque construction and emphasize the contributions of skilled artisans. [...] For example, the repeated invocation of the names of Muhammad and the Twelve Imams in Kufic script highlights the Shi'ite character of the mosque and links its construction to the broader context of the Ilkhanid state's official adoption of Shi'ism under Oljeitu. [...] This inscription, commissioned during the reign of the Aq Qoyunlu ruler Uzun Hasan, also underscores the enduring practice of pious patronage for mosque upkeep and renovation.

> Somali cuisine is an intricate and diverse fusion of a multitude of culinary influences, drawing from the rich tapestry of Arab, Indian, and Italian flavours. This culinary tapestry is a direct result of Somalia's longstanding heritage of vibrant trade and bustling commerce. [...]  Additionally, a distinctive feature of Somali culinary tradition is the incorporation of camel meat and milk. They are considered a delicacy and serve as cherished and fundamental elements in the rich tapestry of Somali cuisine. [...]  An enduring testament to the influence of Italian colonial rule in Somalia is the widespread adoption of pasta and lasagne in the local culinary landscape, espicially in the south, showcasing how these dishes have integrated into the traditional diet alongside rice. [...]  Additionally, Somali merchants played a pivotal role in the global coffee trade, being one of the first to export coffee beans.

### Avoidance of basic copulatives ("is"/"are" phrases)

> Words to watch: ***serves as/stands as/marks/functions as/operates as/represents [a]*, *boasts/features/maintains/offers [a]*, *refers to***

LLM-generated text often replaces simple constructions that use copulas such as *is* or *are* with constructions such as *serves as a* or *mark the*. This pattern has been observed in GPT and Gemini models. One study documented an over 10% decrease in the usage of the words *is* and *are* in academic writing in 2023, with no major changes in their frequency before that. Similarly, LLMs prefer to use marketing-related verbs like *features*, *offers*, and the like to their neutral synonym *has*. (Note: Do not confuse this with *has* used in the past perfect form, as in *has been featured*.) Sometimes--especially in more recent AI output--these constructions are more elaborate, e.g., *ventured into politics as a candidate* versus *was a candidate*, or *began his career as* versus *was*.

A similar decline in "is"/"are" constructions has been observed on Wikipedia, especially when controlling for lead paragraphs (which usually follow a formulaic structure of "[article subject] is...]" and thus skew the data). It is particularly visible in AI copyedits, which will often "improve" text in this way. The study above also demonstrated that when GPT-3.5 was prompted to "Revise the following sentence" in 10,000 abstracts, the words *is* and *are* appeared less often in the revised versions.

In lead sentences, LLMs will sometimes avoid *is* by writing *refers to* as though the article were about the word or term instead of the subject directly.

**Examples**

|  |  |  |  |
| --- | --- | --- | --- |
| − | Gallery 825 on [[La Cienega ~~Boulevard]],~~~~which~~~~was~~~~purchased~~~~in~~ ~~1958,~~ ~~is~~ LAAA's exhibition ~~arm~~ for ~~[[contemporary~~ ~~art]]~~. ~~There~~ ~~are~~ ~~four~~ ~~individual~~ ~~gallery~~ spaces[...] | + | Gallery 825 on [[La Cienega Boulevard]] serves as LAAA's exhibition space for contemporary art. The gallery features four separate spaces[...] |

—From this August 2023 revision to Los Angeles Art Association

|  |  |  |  |
| --- | --- | --- | --- |
| − | It ~~is~~ Malaysia's first ~~[[Malay~~~~language|Malay]]~~~~daily~~ afternoon [[Tabloid ~~(newspaper~~~~format)|Tabloid]]~~ [...] ~~The~~~~''Harian~~~~Metro''~~~~was~~ ~~established~~ ~~in~~ ~~March~~ ~~1991~~ ~~and~~ ~~is~~ the first and oldest Malay-language tabloid [...] | + | It was established in March 1991 as Malaysia's first Malay-language afternoon [[Tabloid journalism|tabloid]] [...] Harian Metro holds the distinction of being the first and oldest Malay-language tabloid [...] |

—From this November 2024 revision to Harian Metro

### Negative parallelisms

When LLMs describe a subject, their output may seem as though it is clearing up a common misconception, or as though the audience may be reaching an incomplete or incorrect conclusion about that subject. This kind of contrast can come across as trying to retroactively challenge such thinking by pointing out another characteristic that the subject may possess alongside (or in the place of) one or more previously-mentioned characteristics. While it is common among human writers (especially in "common misconceptions" or "myths busted" listicles), it is stereotypically an "AI sign."

#### Not just X, but also Y

It is common for LLMs to use parallel constructions involving "not", "but", or "however" such as "Not only ... but ..." or "It is not just ..., it's ...".

**Examples**

— From this August 2024 comment at Talk:Eric Dick (lawyer):
> In your most recent exchange, you referred to another editor’s comment as "bizarre" and "totally incorrect," following up with an assertion that their viewpoint was "bogus." This choice of language is not only dismissive but also unnecessarily harsh and confrontational. It shuts down the possibility of constructive dialogue and disrespects the effort that others put into contributing to this platform.  This kind of dismissive and confrontational attitude is not new. [...] This remark doesn’t just undermine the editor’s argument; it questions their very right to participate based on how long they’ve been active, which is contrary to the inclusive nature that Wikipedia aims to foster. New contributors should be encouraged, not belittled, and it’s disheartening to see you take such a dismissive stance.  Your sarcastic remark about adding "Eric Dick is a secret Democrat. [citation needed]" to the article further exemplifies this problematic behavior. Rather than engaging in a meaningful discussion, you chose to mock another editor’s argument, which only serves to create a hostile environment. This approach doesn’t help resolve disputes or improve content; it only escalates tensions and discourages productive collaboration.  Moreover, in another instance, you accused an editor of "bludgeoning discussion with screeds of AI generated waffle" and dismissed their contributions as "acres of fanciful extrapolation on Wikipedia policies." These comments are not just dismissive—they’re outright disrespectful. Accusations like these don’t belong in a professional and collaborative setting. They undermine the very spirit of Wikipedia, which is built on the idea that people with different perspectives can come together to create something valuable.  It’s important to recognize that everyone who contributes to Wikipedia—whether they’re new or experienced, whether they agree with you or not—deserves to be treated with respect. Collaboration, not confrontation, should be the goal. By continuing to engage with others in such a dismissive and harsh manner, you not only discourage participation but also damage the collaborative spirit that is essential to Wikipedia’s success.

> **Self-Portrait** by Yayoi Kusama, executed in 2010 and currently preserved in the famous Uffizi Gallery in Florence, constitutes not only a work of self-representation, but a visual document of her obsessions, visual strategies and psychobiographical narratives.

— From this August 2025 comment at Wikipedia:Articles for deletion/Northern English nationalism:
> I appreciate the feedback so far, but I want to clarify something that’s being overlooked. The issue here isn’t just sourcing—it’s framing. There’s a visible, growing movement around Northern English identity, documented across academic literature, social media, and grassroots activism. The fact that it doesn’t always use the exact phrase “Northern English nationalism” doesn’t mean it doesn’t exist. Movements evolve before they’re neatly labelled.  TikTok campaigns, dialect revival, and regional symbolism (like St Oswald’s stripes) are part of a broader cultural shift. Dismissing these as “not notable” or “original research” while allowing pages on Cornish nationalism, Wessex regionalism, and Yorkshire separatism suggests an inconsistency in how regional identity is treated. That’s not just a sourcing issue—it’s a systemic bias.

Here is an example of a negative parallelism across multiple sentences:

> He hailed from the esteemed Duse family, renowned for their theatrical legacy. Eugenio's life, however, took a path that intertwined both personal ambition and familial complexities.

— From this April 2025 revision to Eugenio Duse

#### Not X, but Y

Another common LLM pattern is parallelisms that explicitly state that a particular item doesn't possess the first characteristic at all. Such constructions are often expressed as "It's not ..., it's ..." or "no ..., no ..., just ...".

**Examples**

> The viewer is presented with a self-image that is not grounded in visual mastery, but in what Amelia Jones terms “the performative enactment of subjectivity”.  [...]  This dispersal is not dissolution. Rather, it constitutes what Deleuze might describe as “becoming”—an identity in flux, constituted through iterative difference. Through this lens, Kusama’s self-portrait is not a mirror but a portal: not a representation of self, but a mechanism for its constant reinvention.

— From this June 2025 comment at Wikipedia:Articles for deletion/Lilly Contino:
> You say these sources “cover multiple events”? False. They echo the same viral incident and do it through a limited lens. This isn’t WP:NBIO — it’s WP:1EVENT in disguise, trying to wear a press badge like armor.  [...]  Now let’s talk BLP1E: This person is only in the news because of one isolated controversy. Not a career, not a body of work, not sustained relevance — just an algorithmic moment. And if we’re really upholding Wikipedia’s values, we don’t preserve pages built on the backs of virality alone, especially when it risks long-term harm to a living subject without lasting notability.  “Might as well get back on topic.”  Then let’s stay on topic, and the topic is not who feels warm fuzzies from visibility, it’s whether this article meets the threshold for inclusion. It doesn’t.  And finally — if you don’t want “a wall of text,” maybe don’t build a wall of shallow logic and expect people not to knock it down. This ain’t bludgeoning — it’s surgical teardown of a weak argument hiding behind fake neutrality.

#### X rather than Y

This pattern may also be reversed, a construction particularly common in Grok output.

**Examples**

> Chiang's strategy emphasized military suppression of these holdouts to enforce subordination, prioritizing empirical consolidation of power amid fragmented loyalties rather than ideological purity.

— From this April 2026 revision to First Battle of Guilin, which explicitly states it is from Grokipedia

### Rule of three

LLMs overuse the rule of three. This can take different forms, from "adjective, adjective, adjective" to "short phrase, short phrase, and short phrase". LLMs often use this structure to make superficial analyses appear more comprehensive.

**Examples**

> * \*\*Standard Rotary Saws\*\*: Typically used for drywall and light materials.
> * \*\*Heavy-Duty Rotary Saws\*\*: Designed for tougher materials such as tiles, metals, and plastics.
> * \*\*Corded and Cordless Versions\*\*: Corded rotary saws offer continuous power, while cordless versions provide portability and convenience
>
> [...]
>
> * \*\*Construction and Renovation\*\*: For cutting drywall, plywood, and other construction materials.
> * \*\*Electrical and Plumbing\*\*: To create openings for electrical outlets, switches, and plumbing fixtures.
> * \*\*Hobby and Craft\*\*: Used in model making, woodworking, and other craft projects.
> * \*\*Automotive\*\*: Employed in auto body repair and modification tasks.

— From this July 2024 revision to Rotary saw (note that these are canned-format lists that used Markdown)

### Lexical diversity/elegant variation

Generative AI has a repetition-penalty code, meant to discourage it from reusing words too often. This pattern has also been observed on Wikipedia on a broad level: both when comparing Wikipedia text from before 2023 to Wikipedia text from after 2023, and comparing the older Wikipedia text to "Wikipedia-style articles" generated by GPT-4o-mini and Gemini-1.5-Flash.

Note: If a user adds multiple pieces of AI-generated content in separate edits, this tell may not apply, as each piece of text may have been generated in isolation.

**Examples**

> Vierny, after a visit in Moscow in the early 1970’s, committed to supporting artists resisting the constraints of socialist realism and discovered Yankilevskly, among others such as Ilya Kabakov and Erik Bulatov. In the challenging climate of Soviet artistic constraints, Yankilevsky, alongside other non-conformist artists, faced obstacles in expressing their creativity freely. Dina Vierny, recognizing the immense talent and the struggle these artists endured, played a pivotal role in aiding their artistic aspirations. [...]
>
> In this new chapter of his life, Yankilevsky found himself amidst a community of like-minded artists who, despite diverse styles, shared a common goal—to break free from the confines of state-imposed artistic norms, particularly socialist realism. [...]
>
> The move to Paris facilitated an environment where Yankilevsky could further explore and exhibit his distinctive artistic vision without the constraints imposed by the Soviet regime. Dina Vierny's unwavering support and commitment to the Russian avant-garde artists played a crucial role in fostering a space where their creativity could flourish, contributing to the rich tapestry of artistic expression in the vibrant cultural landscape of Paris. Vierny's commitment culminated in the groundbreaking exhibition "Russian Avant-Garde - Moscow 1973" at her Saint-Germain-des-Prés gallery, showcasing the diverse yet united front of non-conformist artists challenging the artistic norms of their time.

— From this February 2024 revision to Vladimir Yankilevsky

It must be noticed however that editors who are not native English speakers might prefer to avoid repeated words as well. For example Italian schools often teach to avoid repeating words.
