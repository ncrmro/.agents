# AI-writing tells: chatbot remnants
> Derived from [Wikipedia:Signs of AI writing](https://en.wikipedia.org/wiki/Wikipedia:Signs_of_AI_writing) (CC BY-SA 4.0), retrieved 2026-07-23; wiki links, citations, and page furniture stripped for reviewer-agent use. The full vendored copy with provenance is `signs-of-ai-writing.md`.

Text that leaked from the chat session into the deliverable — collaborative filler, knowledge-cutoff disclaimers, placeholders, and model-specific citation artifacts.

### Collaborative communication

> Words to watch: ***I hope this helps*, *Of course!*, *Certainly!*, *You're absolutely right!*, *Would you like...*, *is there anything else*, *let me know*, *more detailed breakdown*, *here is a* ...**

Editors sometimes paste text from an AI chatbot that was meant as correspondence, prewriting or advice, rather than article content. This may appear in article text or within comments (<-- -->). Chatbots prompted to produce a Wikipedia article or comment may also explicitly state that the text is meant for Wikipedia, and may mention various policies and guidelines in the output—often explicitly specifying that they're *Wikipedia*'s conventions. Often the advice given by an AI chatbot is incorrect, misleading, or in contravention with policies or guidelines.

**Examples**

> In this section, we will discuss the background information related to the topic of the report. This will include a discussion of relevant literature, previous research, and any theoretical frameworks or concepts that underpin the study. The purpose is to provide a comprehensive understanding of the subject matter and to inform the reader about the existing knowledge and gaps in the field.

— From this August 2023 revision to Metaphysics

> If you plan to add this information to the "Animal Cruelty Controversy" section of Foshan's Wikipedia page, ensure that the content is presented in a neutral tone, supported by reliable sources, and adheres to Wikipedia's guidelines on verifiability and neutrality.

— From this March 2025 revision to Foshan

> Here's a template for your wiki user page. You can copy and paste this onto your user page and customize it further.

— From this May 2025 revision to a user page

> Including photos of the forge (as above) and its tools would enrich the article’s section on culture or economy, [...] Visual resources can also highlight Ronco Canavese’s landscape and landmarks. For instance, a map [...] could be added to orient readers geographically. The village’s scenery [...] could be illustrated with an image. Several such photographs are available (e.g., on Wikimedia Commons) that show Ronco’s panoramic view, [...] Historical images, if any exist [...] would also add depth to the article. Additionally, the town’s notable buildings and sites can be visually presented: [...] Including an image of the Santuario di San Besso [...] could further engage readers. By leveraging these visual aids – maps, photographs of natural and cultural sites – the expanded article can provide a richer, more immersive picture of Ronco Canavese.

— From this May 2025 revision to Ronco Canavese

> ```
> Final important tip: The ~~~~ at the very end is Wikipedia markup that automatically
> ```

— From this June 2025 revision to Talk:Test automation management tools; the message also ends unexpectedly

> Delete this section before submission. After pasting the article, convert as many items as possible in the citation list into inline references attached to the exact sentences they support. If a reviewer questions print-era sources, explain that the article relies on identifiable published books, journals and newspapers from the pre-internet period, several of which survive only as scans from original printed copies.

— From this April 2026 revision to Draft:Gurmukh Singh Jeet

> ```
> <!-- WIKIPEDIA DRAFT — Triple Entry Accounting, version 2 -->
> <!-- Written to Wikipedia Manual of Style. Neutral tone, sourced throughout. -->
> <!-- Author has declared a conflict of interest. Submit via WP:AFC. -->
> <!-- Disclose COI on Talk page and in edit summary before saving. -->
> ```
>
> ```
> <!-- SUBMISSION NOTES -->
> <!-- 1. This article should be created at "Triple Entry Accounting" (not "Triple-entry accounting" — follow Grigg's own capitalisation in the JRFM title). -->
> <!-- 2. The existing article [[Momentum accounting and triple-entry bookkeeping]] needs a hatnote added pointing here. -->
> <!-- 3. Submit via WP:AFC (Articles for Creation), not directly to mainspace. -->
> <!-- 4. Declare COI explicitly: in the AFC submission notes, on the article Talk page, and in the edit summary. -->
> <!-- 5. Post to WP:COIN (Conflict of Interest Noticeboard) after submission. -->
> <!-- 6. The Finanstilsynet citation currently relies on Sunde's paper as intermediary. If a direct sandbox report URL exists on finanstilsynet.no, substitute it. -->
> <!-- 7. The diagram uploaded by the user (showing REA/TEA/Blockchain streams) would be excellent as a figure, but requires CC-BY-SA release by its creator before it can be uploaded to Wikimedia Commons. -->
> ```

— From Draft:Triple Entry Accounting in May 2026, incorrectly advising a user with a COI to self-report to COI/N "after submission".

### Knowledge-cutoff disclaimers and speculation about gaps in sources

> Words to watch: ***as of [date]*, *Up to my last training update*, *as of my last knowledge update*, *While specific details are limited/scarce...*, *not widely available/documented/disclosed*, *...in the provided/available sources/search results...*, *based on available information* ...**

A knowledge-cutoff disclaimer is a statement used by an AI chatbot to indicate that the information provided may be incomplete, inaccurate, or outdated.

If an LLM has a fixed knowledge cutoff, such as older large language models like GPT-3.5 or GPT-4 (usually the model's last training update), it is unable to provide any information on events or developments past that time. Older LLMs would often remind the user about this by outputting a disclaimer that the information in its response is accurate only up to a certain date, and may explicitly mention the knowledge cutoff in doing so.

Newer chatbots with retrieval-augmented generation may also fail to find sources on a given topic, or to find information within the sources a user provides. In these cases, they may output a statement, similar to a knowledge-cutoff disclaimer, claiming that the information is not publicly available. They may also pair it with text about what that information "likely" may be and why it is significant. This information is entirely speculative (including the very claim that it's "not documented") and may be based on loosely related topics or completely fabricated. When that unknown information is about an individual's personal life, this disclaimer often claims that the person "maintains a low profile", "keeps personal details private", etc. This is also speculative.

**Examples**

> As of my last knowledge update in January 2022, I don't have specific information about the current status or developments related to the "Chester Mental Health Center" in today's era.

— From this November 2023 revision to Chester Mental Health Center

> Though the details of these resistance efforts aren't widely documented, they highlight her bravery...

— From this December 2024 revision to Throwing Curves: Eva Zeisel

> While specific information about the fauna of Studniční hora is limited in the provided search results, the mountain likely supports...

— From this March 2025 revision to Studniční hora

> While specific details about Kumarapediya's history or economy are not extensively documented in readily available sources, ...

— From this July 2025 revision to Kumarapediya

> Below is a detailed overview based on available information:

— From Draft:The Good, The Bad, The Dollar Menu 2 (2025)

> As an underground release, detailed lyrics are not widely transcribed on major sites like Genius or AZLyrics, likely due to the artist's limited mainstream exposure. My analysis is based on available track titles, featured artists, public song snippets from streaming platforms (e.g., Spotify, Apple Music, Deezer), and Honcho's overall discography themes. Where lyrics aren't fully accessible, I've inferred common motifs from similar trap tracks and Honcho's style.
> ...For deeper insights, listening to tracks on platforms like Spotify or Deezer is recommended, as lyrics and production details aren't fully documented in public sources.

— From Draft:Haiti Honcho (2026)

### Phrasal templates and placeholder text

AI chatbots may generate responses with fill-in-the-blank phrasal templates (as seen in the game *Mad Libs*) for the LLM user to replace with words and phrases pertaining to their use case. However, some LLM users forget to fill in those blanks. Note that non-LLM-generated templates exist for drafts and new articles, such as Wikipedia:Artist biography article template/Preload and pages in Category:Article creation templates.

**Examples**

> I hope this message finds you well. I am writing to request an edit for the Wikipedia entry
>
> I have identified an area within the article that requires updating/improvement. [Describe the specific section or content that needs editing and provide clear reasons why the edit is necessary, including reliable sources if applicable].

— From this February 2024 revision to Talk:Spaghetti

> We remain committed to creating content that aligns with Wikipedia's mission and are open to further guidance. Please find our revised article [link to the revised article] and a detailed list of sources [link to source list]. We hope to resubmit our work once these changes have been made.
>
> Thank you for your understanding and assistance in this matter.
>
> Best regards, [Your Name] and Chloe

— From this December 2024 revision to Wikipedia:WikiProject Articles for creation/Help desk

> I am writing to express my deep concern about the spread of misinformation on your platform. Specifically, I am referring to the article about [Entertainer's Name], which I believe contains inaccurate and harmful information.

— From this March 2025 revision to Talk:Kjersti Flaa

Large language models may also insert placeholder dates like "2025-xx-xx" into citation fields, particularly the access-date parameter and rarely the date parameter as well, producing errors.

**Examples**

| ``` <ref>{{cite web  |title=Canadian Screen Music Awards 2025 Winners and Nominees  |url=URL  |website=Canadian Screen Music Awards  |date=2025  |access-date=2025-XX-XX }}</ref>  <ref>{{cite web  |title=Best Original Score, Dramatic Series or Special – Winner: "Murder on the Inca Trail"  |url=URL  |website=Canadian Screen Music Awards  |date=2025  |access-date=2025-XX-XX }}</ref> ``` |

In some cases, LLM-generated citations may also contain placeholders in other fields.

**Examples**

| {{cite web  |url=INSERT\_SOURCE\_URL\_30  |title=Deputy Monitoring of Regional Assistance to Mobilized Soldiers  |date=2022-11-XX  |publisher=SOURCE\_PUBLISHER  |accessdate=2024-07-21 }} |

| <ref>{{cite web  |title=Ecos de Amor – Spotify  |url=PASTE\_SPOTIFY\_TRACK\_URL\_HERE  |website=Spotify  |access-date=2026-02-09 }}</ref> <ref>{{cite web  |title=Jesse & Joy – Ecos de Amor (Official Music Video)  |url=PASTE\_YOUTUBE\_VIDEO\_URL\_HERE  |website=YouTube  |access-date=2026-02-09 }}</ref> |

LLM-generated infobox edits may contain comments stating that text or images should be added if sources are found. Note: Comments in infoboxes, especially older infoboxes, are common—some templates automatically include them—and not an indicator of AI use. Anything but "Add \_\_\_\_", or variations on that specific wording, is actually more likely to indicate human text. Even then, there are exceptions; for example, articles with Template:Infobox military person often contain the boilerplate "Add spouse if reliably sourced", which predates LLMs.

**Examples**

> | leader\_name = <!-- Add if available with citation -->

— From this July 2025 revision to Pindi Saidpur

### Leftover machine artifacts (grep for these)

Distilled from the guide's Markup section: literal strings that chatbots emit
as citation/formatting internals. Any hit is near-certain evidence of pasted,
unreviewed AI output.

- ChatGPT: `contentReference`, `oaicite`, `oai_citation`, `turn0search`,
  `turn0news`, `attributableIndex`, stray `+1` after source names
- Gemini: `[cite: 1]`, `span_1`, `start_span`, `end_span`
- Grok: `grok_card`, `grok_render_citation_card_json`
- DeepSeek: lenticular-bracket citations `【 】`, dagger symbols `†` as refs
- Perplexity: `attached_file`, `ppl-ai-file-upload`
- Various: `:::writing` fences, raw `**bold**`/`##` Markdown in a non-Markdown
  medium, `[Insert X here]`-style placeholders
