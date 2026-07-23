# Signs of AI writing — Wikipedia field guide (local copy)

> Local copy of [Wikipedia:Signs of AI writing](https://en.wikipedia.org/wiki/Wikipedia:Signs_of_AI_writing),
> retrieved 2026-07-23. Text licensed [CC BY-SA 4.0](https://creativecommons.org/licenses/by-sa/4.0/);
> see the page history for authorship. Converted from the live page — refresh the copy if it drifts stale.
>
> Written to detect undisclosed AI text *on Wikipedia*, so some sections are wiki-specific.
> For general prose review the high-value sections are **Content**, **Language and grammar**,
> **Style**, and **Communication intended for the user**. The **Markup**, **Citations**, and
> **Edit summaries** sections mostly matter only for wiki/CMS content.
>
> Reviewer agents should not read this file directly: cleaned per-lens splits
> (`content-tells.md`, `language-tells.md`, `style-tells.md`,
> `communication-tells.md`) live beside it, regenerable from this copy. This
> full copy is the vendored source of truth for provenance and re-derivation.

"Wikipedia:AI writing" redirects here. For identifying comments in discussions, see [Wikipedia:Signs of AI-generated comments](https://en.wikipedia.org/wiki/Wikipedia%3ASigns_of_AI-generated_comments "Wikipedia:Signs of AI-generated comments"). For other uses, see [Wikipedia:Artificial intelligence resources](https://en.wikipedia.org/wiki/Wikipedia%3AArtificial_intelligence_resources "Wikipedia:Artificial intelligence resources").

Advice on editing Wikipedia

|  |  |  |
| --- | --- | --- |
| ![](https://upload.wikimedia.org/wikipedia/commons/thumb/7/7e/Essay.svg/40px-Essay.svg.png) | **This is an [advice page](https://en.wikipedia.org/wiki/Wikipedia%3AWikiProject_Council/Guide#Advice_pages "Wikipedia:WikiProject Council/Guide") from [WikiProject AI Cleanup](https://en.wikipedia.org/wiki/Wikipedia%3AWikiProject_AI_Cleanup "Wikipedia:WikiProject AI Cleanup").**  This page is not a [Wikipedia policy](https://en.wikipedia.org/wiki/Wikipedia%3APolicies_and_guidelines "Wikipedia:Policies and guidelines"), as it has not been [reviewed by the community](https://en.wikipedia.org/wiki/Wikipedia%3AConsensus#Levels_of_consensus "Wikipedia:Consensus"). | [Shortcuts](https://en.wikipedia.org/wiki/Wikipedia%3AShortcut "Wikipedia:Shortcut")  * [WP:AISIGNS](https://en.wikipedia.org/w/index.php?title=Wikipedia:AISIGNS&redirect=no)[WP:AISIGNS](https://en.wikipedia.org/wiki/Wikipedia%3AAISIGNS "Wikipedia:AISIGNS") * [WP:AITELLS](https://en.wikipedia.org/w/index.php?title=Wikipedia:AITELLS&redirect=no)[WP:AITELLS](https://en.wikipedia.org/wiki/Wikipedia%3AAITELLS "Wikipedia:AITELLS") * [WP:LLMSIGNS](https://en.wikipedia.org/w/index.php?title=Wikipedia:LLMSIGNS&redirect=no)[WP:LLMSIGNS](https://en.wikipedia.org/wiki/Wikipedia%3ALLMSIGNS "Wikipedia:LLMSIGNS") |

[![A screenshot of ChatGPT reading: "[header] Legacy & Interpretation [body] The "Black Hole Edition" is not just a meme — it's a celebration of grassroots car culture, where ideas are limitless and fun is more important than spec sheets. Whether powered by a rotary engine, a V8 swap, or an imagined fighter jet turbine, the Miata remains the canvas for car enthusiasts worldwide."](https://upload.wikimedia.org/wikipedia/commons/thumb/5/59/ChatGPT_response_screenshot_1.jpg/250px-ChatGPT_response_screenshot_1.jpg)](https://en.wikipedia.org/wiki/File%3AChatGPT_response_screenshot_1.jpg)

LLMs tend to have an identifiable writing style.

This is a list of writing and formatting conventions typical of [AI chatbots](https://en.wikipedia.org/wiki/AI_chatbot "AI chatbot") such as [ChatGPT](https://en.wikipedia.org/wiki/ChatGPT "ChatGPT"), with real examples taken from Wikipedia articles, drafts, comments, and other content. It is a [field guide](https://en.wikipedia.org/wiki/Field_guide "Field guide") to help detect [undisclosed AI-generated content](https://en.wikipedia.org/wiki/Wikipedia%3ALLMDISCLOSE "Wikipedia:LLMDISCLOSE") *on Wikipedia*: while some of the signs may be broadly applicable, some may not apply in a non-Wikipedia context.[[a]](https://en.wikipedia.org/wiki/Wikipedia%3ASigns_of_AI_writing#cite_note-1) Not all text featuring these indicators is AI-generated, as the [large language models](https://en.wikipedia.org/wiki/Large_language_model "Large language model") that power AI chatbots are trained on human writing, including Wikipedia. Many elements of AI writing can be found in editorials, blogs, or fan fiction.

Moreover, this list is *descriptive*, not *prescriptive*; it consists of observations, not rules. Advice about formatting or language to avoid can be found in the [policies and guidelines](https://en.wikipedia.org/wiki/Wikipedia%3APAG "Wikipedia:PAG") and the [Manual of Style](https://en.wikipedia.org/wiki/Wikipedia%3AMOS "Wikipedia:MOS"), but does not belong on this page.

**The patterns listed here are also only potential *signs* of a problem, not *the problem itself*.** While many of these issues are immediately obvious and easy to fix—e.g., excessive boldface, broken markup, citation style quirks—they can point to less outwardly visible problems that carry [much more serious policy risks](https://en.wikipedia.org/wiki/Wikipedia%3AAIFAIL "Wikipedia:AIFAIL"). **Please do not merely treat these signs as the problems to be fixed; that could just make detection harder.** The actual problems are those deeper concerns, so make sure to address them, either yourself or by flagging them, per the [relevant guide](https://en.wikipedia.org/wiki/Wikipedia%3AWikiProject_AI_Cleanup/Guide "Wikipedia:WikiProject AI Cleanup/Guide").

The [speedy deletion policy](https://en.wikipedia.org/wiki/Wikipedia%3ASpeedy_deletion "Wikipedia:Speedy deletion") criterion [G15](https://en.wikipedia.org/wiki/Wikipedia%3AG15 "Wikipedia:G15") (LLM-generated pages without human review) lists some signs of AI writing, but is limited to the most objective ones. The remaining signs covered here are not sufficient on their own for speedy deletion.

## Caveats

### AI detection tools

[Shortcut](https://en.wikipedia.org/wiki/Wikipedia%3AShortcut "Wikipedia:Shortcut")

* [WP:AIDETECTION](https://en.wikipedia.org/w/index.php?title=Wikipedia:AIDETECTION&redirect=no)[WP:AIDETECTION](https://en.wikipedia.org/wiki/Wikipedia%3AAIDETECTION "Wikipedia:AIDETECTION")

Do not solely rely on [artificial intelligence content detection](https://en.wikipedia.org/wiki/Artificial_intelligence_content_detection "Artificial intelligence content detection") tools (such as [GPTZero](https://en.wikipedia.org/wiki/GPTZero "GPTZero")). While they perform better than random chance, these tools have non-trivial error rates.[[1]](https://en.wikipedia.org/wiki/Wikipedia%3ASigns_of_AI_writing#cite_note-Russell-2)[[2]](https://en.wikipedia.org/wiki/Wikipedia%3ASigns_of_AI_writing#cite_note-dik2025-3) Detectors can be susceptible to factors such as text modifications (e.g. paraphrasing, markup, and spacing changes) and the use of models not seen during detector training.[[3]](https://en.wikipedia.org/wiki/Wikipedia%3ASigns_of_AI_writing#cite_note-4) A high percentage of detected AI writing from the results of a detection tool is **not** a valid criterion for speedy deletion under G15.

### Your detection ability

[Shortcut](https://en.wikipedia.org/wiki/Wikipedia%3AShortcut "Wikipedia:Shortcut")

* [WP:AIDETECTIVE](https://en.wikipedia.org/w/index.php?title=Wikipedia:AIDETECTIVE&redirect=no)[WP:AIDETECTIVE](https://en.wikipedia.org/wiki/Wikipedia%3AAIDETECTIVE "Wikipedia:AIDETECTIVE")

|  |  |
| --- | --- |
|  | **Test your AI detection skills at [Wikipedia:AI or not quiz](https://en.wikipedia.org/wiki/Wikipedia%3AAI_or_not_quiz "Wikipedia:AI or not quiz").** |

Do not rely too much on your own judgment. Humans are notoriously bad at distinguishing human and LLM-generated text. While research on humans' abilities to detect AI-generated text is still limited, a 2025 study has shown that human ability to distinguish LLM text from human is no better than random chance.[[4]](https://en.wikipedia.org/wiki/Wikipedia%3ASigns_of_AI_writing#cite_note-cheng2025-5) Another 2025 study on German theses has shown that humans managed a "recognition rate of 57 % for AI texts and 64 % for human-generated texts".[[5]](https://en.wikipedia.org/wiki/Wikipedia%3ASigns_of_AI_writing#cite_note-fiedler2025-6)

A 2025 preprint has shown that heavy users of LLMs can correctly determine whether an article was generated by AI about 90% of the time, which means that if you are an expert user of LLMs and you tag 10 pages as being AI-generated, you've probably made one false positive. Study participants who didn't use LLMs much did only slightly better than random chance (in both directions).[[1]](https://en.wikipedia.org/wiki/Wikipedia%3ASigns_of_AI_writing#cite_note-Russell-2)

Note, also, that human speech and writing is being influenced by LLMs, and thus they are becoming more similar. This was already evident in 2024, as shown by a study that detected a significant LLM influence in spoken content (e.g. conversational podcasts).[[6]](https://en.wikipedia.org/wiki/Wikipedia%3ASigns_of_AI_writing#cite_note-yakura2024-7) Further studies seem to confirm this influence on language,[[7]](https://en.wikipedia.org/wiki/Wikipedia%3ASigns_of_AI_writing#cite_note-geng2025-8) including semantics and word choices.[[8]](https://en.wikipedia.org/wiki/Wikipedia%3ASigns_of_AI_writing#cite_note-galpin2025-9)

It is also worth noting that writers may adjust their behavior to avoid accusations of AI, or may be defensive about using AI tropes.

## Content

[Shortcuts](https://en.wikipedia.org/wiki/Wikipedia%3AShortcut "Wikipedia:Shortcut")

* [WP:AIWTW](https://en.wikipedia.org/w/index.php?title=Wikipedia:AIWTW&redirect=no)[WP:AIWTW](https://en.wikipedia.org/wiki/Wikipedia%3AAIWTW "Wikipedia:AIWTW")
* [WP:AI-ISM](https://en.wikipedia.org/w/index.php?title=Wikipedia:AI-ISM&redirect=no)[WP:AI-ISM](https://en.wikipedia.org/wiki/Wikipedia%3AAI-ISM "Wikipedia:AI-ISM")
* [WP:LLMISM](https://en.wikipedia.org/w/index.php?title=Wikipedia:LLMISM&redirect=no)[WP:LLMISM](https://en.wikipedia.org/wiki/Wikipedia%3ALLMISM "Wikipedia:LLMISM")

LLMs (and [artificial neural networks](https://en.wikipedia.org/wiki/Artificial_neural_network "Artificial neural network") in general) use statistical algorithms to guess (infer) what should come next based on a large corpus of training material. It thus tends to [regress to the mean](https://en.wikipedia.org/wiki/Regression_to_the_mean "Regression to the mean"); that is, the result tends toward the most statistically likely result that applies to the widest variety of cases. It can simultaneously be a strength and a "tell" for detecting AI-generated content.

For example, LLMs are usually trained on data from the internet in which famous people are generally described with positive, important-sounding language. Consequently, the LLM tends to omit specific, unusual, nuanced facts (which are statistically rare) and replace them with more generic, positive descriptions (which are statistically common). Thus the highly specific "inventor of the first train-coupling device" might become "a revolutionary titan of industry". It is like shouting louder and louder that a portrait shows a uniquely important person, while the portrait itself is fading from a sharp photograph into a blurry, generic sketch. The subject becomes simultaneously less specific and more exaggerated.[[b]](https://en.wikipedia.org/wiki/Wikipedia%3ASigns_of_AI_writing#cite_note-10)

This statistical regression to the mean, a smoothing over of specific facts into generic statements, that could equally apply to many topics, makes AI-generated content easier to detect.

### Undue emphasis on significance, legacy, and broader trends

[Shortcuts](https://en.wikipedia.org/wiki/Wikipedia%3AShortcut "Wikipedia:Shortcut")

* [WP:AILEGACY](https://en.wikipedia.org/w/index.php?title=Wikipedia:AILEGACY&redirect=no)[WP:AILEGACY](https://en.wikipedia.org/wiki/Wikipedia%3AAILEGACY "Wikipedia:AILEGACY")
* [WP:AITREND](https://en.wikipedia.org/w/index.php?title=Wikipedia:AITREND&redirect=no)[WP:AITREND](https://en.wikipedia.org/wiki/Wikipedia%3AAITREND "Wikipedia:AITREND")

|  |  |
| --- | --- |
|  | Words to watch: ***stands/serves as*, *is a testament/reminder*, *a crucial/pivotal/vital/significant/key role/moment*, *underscores/highlights its importance/significance*, *reflects broader*, *symbolizing its ongoing/enduring/lasting*, *contributing to the*, *setting the stage for*, *marking/shaping the*, *represents/marks a shift*, *key turning point*, *evolving landscape*, *focal point*, *indelible mark*, *deeply rooted*,  ...** |

LLM writing often [puffs up](https://en.wikipedia.org/wiki/Wikipedia%3APuffery "Wikipedia:Puffery") the importance of the subject matter by adding statements about how arbitrary aspects of the topic represent or contribute to a broader topic.[[9]](https://en.wikipedia.org/wiki/Wikipedia%3ASigns_of_AI_writing#cite_note-chronicle-11)[[10]](https://en.wikipedia.org/wiki/Wikipedia%3ASigns_of_AI_writing#cite_note-sun-12) There is a distinct and easily identifiable repertoire of ways that it writes these statements.[[11]](https://en.wikipedia.org/wiki/Wikipedia%3ASigns_of_AI_writing#cite_note-Juzek-13)

**Examples**

| From [this September 2024 revision](https://en.wikipedia.org/wiki/Special%3ADiff/1252053288 "Special:Diff/1252053288") to [Statistical Institute of Catalonia](https://en.wikipedia.org/wiki/Statistical_Institute_of_Catalonia "Statistical Institute of Catalonia") |
| --- |
| The Statistical Institute of Catalonia was officially established in 1989, marking a pivotal moment in the evolution of regional statistics in Spain. [...]  The founding of Idescat represented a significant shift toward regional statistical independence, enabling [Catalonia](https://en.wikipedia.org/wiki/Catalonia "Catalonia") to develop a statistical system tailored to its unique socio-economic context. This initiative was part of a broader movement across Spain to decentralize administrative functions and enhance regional governance. |

| From [this October 2024 revision](https://en.wikipedia.org/wiki/Special%3ADiff/1248482444 "Special:Diff/1248482444") to [Kumba, Cameroon](https://en.wikipedia.org/wiki/Kumba%2C_Cameroon "Kumba, Cameroon") |
| --- |
| Kumba has long been an important center for trade and agriculture. [...] The establishment of road networks connecting Kumba to other parts of the Southwest Region, such as Mamfe and Buea, helped solidify its role as a regional hub. |

Another common manifestation of this sign is AI chatbots situating an article subject amid broader "debates" or "discussions".

| From [this October 2025 revision](https://en.wikipedia.org/wiki/Special%3ADiff/1317624451 "Special:Diff/1317624451") to [Deadbot](https://en.wikipedia.org/wiki/Deadbot "Deadbot") |
| --- |
| The phenomenon has generated debate about authenticity, consent, and the psychological effects of digitally extending personhood.  [...]  Collectively, these works have shaped emerging policy discussions about ownership, consent, and dignity in digital resurrection technologies.  [...]  GriefBots have prompted broader reflection on mortality and memory in a digital age. They blur boundaries between life and data, raising philosophical questions about identity, authenticity, and what it means to “live on” through algorithms. |

LLMs may even include these statements for even the most mundane of subjects like etymology or population data. Sometimes, they add hedging preambles acknowledging that the subject is of relatively low importance, before talking about its importance anyway.

> During the [Spanish colonial period](https://en.wikipedia.org/wiki/Spanish_Colonial_Period_%28Philippines%29 "Spanish Colonial Period (Philippines)"), the name *Bakunutan* was hispanized to *Bacnotan*, a modification reflected in official documents preserved in the [National Archives](https://en.wikipedia.org/wiki/National_Archives_of_the_Philippines "National Archives of the Philippines") in Manila. This etymology highlights the enduring legacy of the community's resistance and the transformative power of unity in shaping its identity.

— From [this December 2024 revision](https://en.wikipedia.org/wiki/Special%3ADiff/1265870147 "Special:Diff/1265870147") to [Bacnotan](https://en.wikipedia.org/wiki/Bacnotan "Bacnotan")

> Though it saw only limited application, it contributes to the broader history of early aviation engineering and reflects the influence of French rotary designs on German manufacturers.

— From [Draft:Goebel Goe II](https://en.wikipedia.org/wiki/Wikipedia%3ASigns_of_AI_writing/Examples/Goebel_Goe_II "Wikipedia:Signs of AI writing/Examples/Goebel Goe II") (July 2025)

When talking about biology (e.g., when asked to discuss an animal or plant species), LLMs tend to over-emphasize connections to the broader ecosystem or environment, even when those connections are tenuous or generic. LLMs also tend to belabor the species' conservation status and research and preservation efforts, even if the status is unknown and no serious efforts exist.

> Currently, there is no specific conservation assessment for *Lethrinops lethrinus* by the International Union for Conservation of Nature (IUCN). However, the general health of the Lake Malawi ecosystem is crucial for the survival of this and other endemic species. Factors such as overfishing, pollution, and habitat destruction could potentially impact their populations.

— From [this July 2024 revision](https://en.wikipedia.org/wiki/Special%3ADiff/1235454313 "Special:Diff/1235454313") to [Lethrinops lethrinus](https://en.wikipedia.org/wiki/Lethrinops_lethrinus "Lethrinops lethrinus")

> It plays a role in the ecosystem and contributes to Hawaii's rich cultural heritage. [...] Preserving this endemic species is vital not only for ecological diversity but also for sustaining the cultural traditions connected to Hawaii’s native flora.

— From [this December 2024 revision](https://en.wikipedia.org/wiki/Special%3ADiff/1262033910 "Special:Diff/1262033910") to [Nototrichium divaricatum](https://en.wikipedia.org/wiki/Nototrichium_divaricatum "Nototrichium divaricatum")

### Canned emphasis on notability, attribution, and media coverage

[Shortcuts](https://en.wikipedia.org/wiki/Wikipedia%3AShortcut "Wikipedia:Shortcut")

* [WP:OVERATTRIBUTION](https://en.wikipedia.org/w/index.php?title=Wikipedia:OVERATTRIBUTION&redirect=no)[WP:OVERATTRIBUTION](https://en.wikipedia.org/wiki/Wikipedia%3AOVERATTRIBUTION "Wikipedia:OVERATTRIBUTION")
* [WP:AIATTR](https://en.wikipedia.org/w/index.php?title=Wikipedia:AIATTR&redirect=no)[WP:AIATTR](https://en.wikipedia.org/wiki/Wikipedia%3AAIATTR "Wikipedia:AIATTR")

|  |  |
| --- | --- |
|  | Words to watch: ***independent coverage*, *local/regional/national/[country name] media outlets*, *music/business/tech outlets*, *trade publications*, *profiled in*, *written by a leading expert*, *active social media presence*** |

Similarly, LLMs act as if the best way to prove that a subject is notable is to hit readers over the head with claims of notability, often by listing sources that a subject has been covered in and specifying what kind of sources they are (e.g., trade publications, regional media, etc). They often inaccurately attribute their own [superficial analyses](https://en.wikipedia.org/wiki/Wikipedia%3ASigns_of_AI_writing#Superficial_analyses) to the source. This is more common in text from AI tools released in 2025 or later.

Human-written press releases have of course also cited news clippings for decades, but LLMs specifically asked to write a Wikipedia article often echo the exact wording of [Wikipedia's guidelines](https://en.wikipedia.org/wiki/Wikipedia%3AN "Wikipedia:N"), such as "independent coverage."

**Examples**

| From [this February 2025 revision](https://en.wikipedia.org/wiki/Special%3ADiff/1276225083 "Special:Diff/1276225083") to [Sinead Bovell](https://en.wikipedia.org/wiki/Sinead_Bovell "Sinead Bovell") |
| --- |
| She spoke about AI on CNN, and was featured in Vogue, Wired, Toronto Star, and other media. [...] Her insights have also been featured in \*Wired\*, \*Refinery29\*, and other prominent media outlets. |

| From [this June 2025 revision](https://en.wikipedia.org/wiki/Special%3ADiff/1294930957 "Special:Diff/1294930957") to [Virginia High School (Minnesota)](https://en.wikipedia.org/wiki/Virginia_High_School_%28Minnesota%29 "Virginia High School (Minnesota)") |
| --- |
| Its significance is documented in archived school event programs and regional press coverage, including the \*Mesabi Daily News\*, which regularly reviewed performances held there. |

| From [this November 2025 AfC help desk comment](https://en.wikipedia.org/wiki/Wikipedia%3AWikiProject_Articles_for_creation/Help_desk/Archives/2025_November_2#06:02,_2_November_2025_review_of_submission_by_Moefry1 "Wikipedia:WikiProject Articles for creation/Help desk/Archives/2025 November 2") |
| --- |
| The subject has been profiled in multiple high-quality, independent, and widely-read outlets, including The Australian, SBS News, 7News, and coverage syndicated through the Associated Press—appearing in platforms like The Senior and Perth Now. These sources provide significant, substantial, secondary coverage, not trivial mentions or press releases.   ---   • Repeated national media coverage for both professional and advocacy work (reported by SBS, 7News, The Australian, etc.) • Leadership roles in international and national health campaigns (e.g., THINK Aorta ANZ and board member of Hearts4Heart) • National ambassador role for the National Heart Foundation of Australia, highlighted by multiple independent reports • Academic and economic contributions recognised by universities, specialist publications, and health system institutions (e.g., University of Sydney, Monash University, RANZCR) • Ongoing public presence in respected media and at speaking events over multiple years, including via independent news commentary, landmark survival stories, and national health initiatives Together, these factors clearly demonstrate significant, sustained, and verifiable coverage—meeting both WP:BIOSIGand WP:SIGCOV. |

On Wikipedia specifically, LLMs often painstakingly emphasize their sources in the body text—even for trivial coverage, uncontroversial facts, or other situations where a human Wikipedia editor would be more likely to either provide an inline citation or no source at all.

**Examples**

> The restaurant has also been mentioned in [ABC News](https://en.wikipedia.org/wiki/ABC_News_%28Australia%29 "ABC News (Australia)") coverage relating to incidents in the surrounding precinct, underscoring its role as a well-known late-night venue in the city [of [Adelaide](https://en.wikipedia.org/wiki/Adelaide "Adelaide")].

— Trivial coverage with attribution, from [this August 2025 revision](https://en.wikipedia.org/wiki/Special%3APermanentLink/1305163154 "Special:PermanentLink/1305163154") to [The Original Pancake Kitchen](https://en.wikipedia.org/wiki/The_Original_Pancake_Kitchen "The Original Pancake Kitchen"); the reference added for this sentence did not exist.

In articles about people or entities that use social media, LLMs will often note that they "maintain an active social media presence" or something similar. This wording is particularly idiosyncratic to AI text and relatively uncommon on Wikipedia before ~2024.

**Examples**

> The mall maintains a strong digital presence, particularly on Instagram, where it actively shares the latest updates and events. Forum Kochi has consistently demonstrated excellence in digital promotions, with high-quality, engaging, and impactful video content playing a key role in its outreach.

— From [this June 2025 revision](https://en.wikipedia.org/wiki/Special%3ADiff/1297291381 "Special:Diff/1297291381") to [Forum Mall Kochi](https://en.wikipedia.org/wiki/Forum_Mall_Kochi "Forum Mall Kochi")

### Superficial analyses

[Shortcut](https://en.wikipedia.org/wiki/Wikipedia%3AShortcut "Wikipedia:Shortcut")

* [WP:SUPERFICIAL](https://en.wikipedia.org/w/index.php?title=Wikipedia:SUPERFICIAL&redirect=no)[WP:SUPERFICIAL](https://en.wikipedia.org/wiki/Wikipedia%3ASUPERFICIAL "Wikipedia:SUPERFICIAL")

|  |  |
| --- | --- |
|  | Words to watch: ***highlighting/underscoring/emphasizing ...*, *ensuring ...*, *reflecting/symbolizing ...*, *contributing to ...*, *cultivating/fostering ...*, *encompassing ...*, *enhancing ...*, *valuable insights*, *align/resonate with*,** |

AI chatbots tend to insert superficial analysis of information, often in relation to its significance, recognition, or impact.[[12]](https://en.wikipedia.org/wiki/Wikipedia%3ASigns_of_AI_writing#cite_note-Reinhart-14) This is often done by attaching a [present participle](https://en.wikipedia.org/wiki/Participle#Forms "Participle") ("-ing") phrase at the end of sentences, sometimes with [vague attributions](https://en.wikipedia.org/wiki/Wikipedia%3AAIWEASEL "Wikipedia:AIWEASEL") to third parties (see below).[[12]](https://en.wikipedia.org/wiki/Wikipedia%3ASigns_of_AI_writing#cite_note-Reinhart-14)[[9]](https://en.wikipedia.org/wiki/Wikipedia%3ASigns_of_AI_writing#cite_note-chronicle-11)

For the purpose of Wikipedia, such comments are usually [synthesis](https://en.wikipedia.org/wiki/Wikipedia%3ASYNTH "Wikipedia:SYNTH") or unattributed opinions. Newer chatbots with [retrieval-augmented generation](https://en.wikipedia.org/wiki/Retrieval-augmented_generation "Retrieval-augmented generation") (for example, an AI chatbot that can search the web) may attach these statements to [named sources](https://en.wikipedia.org/wiki/Wikipedia%3ASigns_of_AI_writing#Undue_emphasis_on_notability,_attribution,_and_media_coverage)—e.g., "Roger Ebert highlighted the lasting influence"—regardless of whether those sources say anything close.

**Examples**

| From [this June 2023 revision](https://en.wikipedia.org/w/index.php?title=&diff=1161677884&oldid=) to [Douéra](https://en.wikipedia.org/wiki/Dou%C3%A9ra "Douéra") |
| --- |
| As of the April 2008 census, the population of Douera stood at approximately 56,998 inhabitants, creating a lively community within its borders. Situated in the central-north region of the country, Douera enjoys close proximity to the capital city, Algiers, further enhancing its significance as a dynamic hub of activity and culture. With its coastal charm and convenient location, Douera captivates both residents and visitors alike, offering a diverse range of experiences against the backdrop of Algeria's stunning natural beauty. |

| From [this August 2024 revision](https://en.wikipedia.org/wiki/Special%3ADiff/1240127604 "Special:Diff/1240127604") to [Darbhanga Junction railway station](https://en.wikipedia.org/wiki/Darbhanga_Junction_railway_station "Darbhanga Junction railway station") |
| --- |
| It holds a pivotal place in the [East Central Railway Zone](https://en.wikipedia.org/wiki/East_Central_Railway_Zone "East Central Railway Zone") of [Indian Railways](https://en.wikipedia.org/wiki/Indian_Railways "Indian Railways"), serving as a major railway hub with historical significance. The station has [1,676 mm](https://en.wikipedia.org/wiki/5_ft_6_in_gauge_railway "5 ft 6 in gauge railway") (5 ft 6 in) [broad gauge](https://en.wikipedia.org/wiki/Broad_gauge "Broad gauge") along with 8 tracks and 6 platforms. [...] Historically, it has been crucial for linking [Darbhanga](https://en.wikipedia.org/wiki/Darbhanga "Darbhanga") with significant cities like [Delhi](https://en.wikipedia.org/wiki/Delhi "Delhi"), [Patna](https://en.wikipedia.org/wiki/Patna "Patna"), and [Kolkata](https://en.wikipedia.org/wiki/Kolkata "Kolkata"), facilitating the movement of passengers and goods. The station has supported various services, including passenger trains and express trains like the [Satyagrah Express](https://en.wikipedia.org/wiki/Satyagrah_Express "Satyagrah Express") and [Mithila Express](https://en.wikipedia.org/wiki/Mithila_Express "Mithila Express"), contributing to the socio-economic development of the region. [...] Over the years, Darbhanga Junction has seen several upgrades and modernization efforts aimed at improving facilities and operational efficiency, reflecting its continued relevance in the regional and national transportation landscape. |

| From [this October 2024 revision](https://en.wikipedia.org/wiki/Special%3ADiff/1253182873 "Special:Diff/1253182873") to [African-American culture](https://en.wikipedia.org/wiki/African-American_culture "African-American culture") |
| --- |
| The civil rights movement emerged as a powerful continuation of this struggle, emphasizing the importance of solidarity and collective action in the fight for justice. This historical legacy has influenced contemporary African-American families, shaping their values, community structures, and approaches to political engagement. Economically, the enduring impacts of systemic inequality have led to both challenges and innovations within African-American communities, driving a commitment to empowerment and social change that echoes through generations. |

| From [this November 2024 revision](https://en.wikipedia.org/wiki/Special%3ADiff/1256905241 "Special:Diff/1256905241") to [McAllen Texas Temple](https://en.wikipedia.org/wiki/McAllen_Texas_Temple "McAllen Texas Temple") |
| --- |
| Situated just a few miles from the U.S.-Mexico border—a line that often represents separation and division—the temple stands as a counter-symbol, emphasizing unity, togetherness, and transcendent faith. In a region where many families and communities span both countries, the temple fosters a sense of connection and shared purpose. Through its inclusive design and symbolic features, the McAllen Texas Temple is seen as a bridge across divides, embodying the spirit of unity that underlies its sacred purpose. Its bilingual monument sign, with inscriptions in both English and Spanish, underscores its role in bringing together Latter-day Saints from the United States and Mexico.  The temple’s architectural and decorative elements are thoughtfully imbued with local symbolism, reflecting the rich culture and landscape of the Rio Grande Valley. Citrus blossom motifs, seen throughout the exterior and interior, celebrate the area’s agricultural roots and its vital citrus industry. The temple’s color palette of blue, green, and gold resonates with the region’s natural beauty, symbolizing Texas bluebonnets, the Gulf of Mexico, and the diverse Texan landscapes. These colors and patterns evoke enduring faith and resilience, qualities that resonate deeply within this close-knit, cross-border community.  In design and structure, the McAllen Texas Temple honors the Spanish colonial heritage that has historically shaped the area. By incorporating these architectural elements, the temple connects to both the Latin American influences and the historic roots of the border region, creating a space where the past and present come together. |

| From [this March 2025 revision](https://en.wikipedia.org/wiki/Special%3ADiff/1279776010 "Special:Diff/1279776010") to [Draft:Jacques Blois](https://en.wikipedia.org/wiki/Wikipedia%3ASigns_of_AI_writing/Examples/Jacques_Blois_%28linguist%29 "Wikipedia:Signs of AI writing/Examples/Jacques Blois (linguist)") |
| --- |
| These works are now part of the \*\*Collections of the National Museum of Education - Réseau Canopé (France)\*\*, highlighting their historical and pedagogical significance.  His influence persists in more recent studies. In 2010, *Les néologismes dans l'hebdomadaire L'Express* (1980) was cited in the *Proceedings of the 1st International Congress on Neology in Romance Languages* [...] demonstrating the ongoing relevance of his research on lexical evolution. [...] In 2004, the *Cahiers de lexicologie* (issues 84-87), published by the [CNRS](https://en.wikipedia.org/wiki/French_National_Centre_for_Scientific_Research "French National Centre for Scientific Research"), cited the *Grammaire Blois*, confirming its relevance in modern research. [...]  These citations, spanning more than six decades and appearing in recognized academic publications, illustrate Blois' lasting influence in computational linguistics, grammar, and neology.  Fridrichová analyzes the distinction made by Blois and Bar between acronyms, abbreviations, and truncations, emphasizing their critical view on the impact of truncations in the French language.  [...]  Fridrichová highlights that Blois and Bar perceive truncations as a \*\*distortion of the language rather than an enrichment\*\*, a perspective that still fuels linguistic debates today. This citation demonstrates the \*\*enduring relevance of Blois's work in modern linguistic studies\*\* and its \*\*critical reception by researchers\*\*. }} |

### Promotional and advertisement-like language

For non-AI-specific guidance about this, see [Wikipedia:Manual of Style/Words to watch § Puffery](https://en.wikipedia.org/wiki/Wikipedia%3AManual_of_Style/Words_to_watch#Puffery "Wikipedia:Manual of Style/Words to watch").

See also: [Wikipedia:Marketing buzzspeak § Marketing buzzspeak and artificial intelligence](https://en.wikipedia.org/wiki/Wikipedia%3AMarketing_buzzspeak#Marketing_buzzspeak_and_artificial_intelligence "Wikipedia:Marketing buzzspeak")

[Shortcuts](https://en.wikipedia.org/wiki/Wikipedia%3AShortcut "Wikipedia:Shortcut")

* [WP:AIPUFFERY](https://en.wikipedia.org/w/index.php?title=Wikipedia:AIPUFFERY&redirect=no)[WP:AIPUFFERY](https://en.wikipedia.org/wiki/Wikipedia%3AAIPUFFERY "Wikipedia:AIPUFFERY")
* [WP:AIPEACOCK](https://en.wikipedia.org/w/index.php?title=Wikipedia:AIPEACOCK&redirect=no)[WP:AIPEACOCK](https://en.wikipedia.org/wiki/Wikipedia%3AAIPEACOCK "Wikipedia:AIPEACOCK")

|  |  |
| --- | --- |
|  | Words to watch: ***boasts a*, *vibrant*, *rich*, *profound*, *enhancing*, *showcasing*, *exemplifies*, *commitment to*, *natural beauty*, *nestled*, *in the heart of*, *groundbreaking*, *renowned*, *featuring*, *diverse array*,  ...** |

LLMs have serious problems keeping a neutral tone. Even when prompted to use an encyclopedic style, their output will often tend toward advertisement-like writing, or like the prose of a travel guide. This may happen when generating new text or rewriting existing text: for instance, an edit summary claiming a rewrite "removed promotional tone" while actually introducing it. This may also happen when editors are not [deliberately trying to advertise](https://en.wikipedia.org/wiki/Wikipedia%3ACOI "Wikipedia:COI") a subject.[[13]](https://en.wikipedia.org/wiki/Wikipedia%3ASigns_of_AI_writing#cite_note-rettberg-15)

Note: Not all promotional or spammy writing is AI-generated. LLMs tend to over-use the same set of promotional phrases no matter what the topic. Also, older LLMs (e.g., GPT-4) tend to output more blatantly positive text[[14]](https://en.wikipedia.org/wiki/Wikipedia%3ASigns_of_AI_writing#cite_note-sussman-16) than newer LLMs, which are more subtly positive and tend to avoid obviously superlative statements like "the best."

#### Subtypes

When writing about something that could be considered "cultural heritage" (even Japan's electronics industry), LLMs [constantly remind the reader of its importance](https://en.wikipedia.org/wiki/Wikipedia%3ASigns_of_AI_writing#Undue_emphasis_on_significance,_legacy,_and_broader_trends).

| From [this June 2023 revision](https://en.wikipedia.org/w/index.php?title=&diff=1162718043&oldid=) to [Alamata (woreda)](https://en.wikipedia.org/wiki/Alamata_%28woreda%29 "Alamata (woreda)") |
| --- |
| Nestled within the breathtaking region of Gonder in Ethiopia, Alamata Raya Kobo stands as a vibrant town with a rich cultural heritage and a significant place within the Amhara region. From its scenic landscapes to its historical landmarks, Alamata Raya Kobo offers visitors a fascinating glimpse into the diverse tapestry of Ethiopia. In this article, we will explore the unique characteristics that make Alamata Raya Kobo a town worth visiting and shed light on its significance within the Amhara region. |

| From [this July 2025 revision](https://en.wikipedia.org/w/index.php?title=&diff=1299567515&oldid=) to [Tamil Nadu Tourism Development Corporation](https://en.wikipedia.org/wiki/Tamil_Nadu_Tourism_Development_Corporation "Tamil Nadu Tourism Development Corporation") |
| --- |
| TTDC acts as the gateway to Tamil Nadu’s diverse attractions, seamlessly connecting the beginning and end of every traveller's journey. It offers dependable, value-driven experiences that showcase the state’s rich history, spiritual heritage, and natural beauty. |

When writing about people or companies, LLMs will often adopt a press-release or commercial-esque tone.

| From [this November 2024 revision](https://en.wikipedia.org/wiki/Special%3ADiff/1259548187 "Special:Diff/1259548187") to [Kenya Airways](https://en.wikipedia.org/wiki/Kenya_Airways "Kenya Airways") |
| --- |
| These projects align with KQ's goals of reducing its environmental footprint, improving operational efficiency, and fostering community development through job creation. CEO Allan Kilavuka emphasized the airline's commitment to sustainability, customer focus, and Africa's prosperity through responsible corporate practices. |

| From [this April 2025 revision](https://en.wikipedia.org/wiki/Special%3ADiff/1285549984 "Special:Diff/1285549984") to [Cadillac Sollei](https://en.wikipedia.org/wiki/Cadillac_Sollei "Cadillac Sollei") |
| --- |
| The SOLLEI’s exterior design communicates a powerful emotional presence, staying true to Cadillac's signature bold proportions. Its low, elongated silhouette is highlighted by a wide stance and an extended coupe door, which enhances accessibility to the spacious rear cabin. Smooth, uninterrupted surfaces and a pronounced A-line accentuate the vehicle’s overall length, while a sleek, low tail imparts a sense of refined dynamism. A mid-body line runs seamlessly from the headlamps to the taillights, reinforcing the car’s cohesive and elegant design. Traditional door handles have been replaced with discrete buttons, preserving the vehicle’s clean and modern profile. In a nod to Cadillac’s legacy of bold color choices, the exterior is finished in "Manila Cream"—a distinctive hue originally offered in 1957 and 1958. This heritage color has been thoughtfully revived and hand-painted by Cadillac artisans, showcasing the brand’s dedication to craftsmanship and historical reverence. |

### Vague attributions and overgeneralization of opinions

For non-AI-specific guidance about this, see [Wikipedia:Manual of Style/Words to watch § Unsupported attributions](https://en.wikipedia.org/wiki/Wikipedia%3AManual_of_Style/Words_to_watch#Unsupported_attributions "Wikipedia:Manual of Style/Words to watch").

[Shortcut](https://en.wikipedia.org/wiki/Wikipedia%3AShortcut "Wikipedia:Shortcut")

* [WP:AIWEASEL](https://en.wikipedia.org/w/index.php?title=Wikipedia:AIWEASEL&redirect=no)[WP:AIWEASEL](https://en.wikipedia.org/wiki/Wikipedia%3AAIWEASEL "Wikipedia:AIWEASEL")

|  |  |
| --- | --- |
|  | Words to watch: ***Industry reports*, *Observers have cited*, *Experts argue*, *Some critics argue*, *several sources/publications* (when only few sources are cited), *such as* (before exhaustive word lists),  ...** |

AI chatbots tend to attribute opinions or claims to some vague authority—a practice called [weasel wording](https://en.wikipedia.org/wiki/Weasel_wording "Weasel wording").

**Examples**

> Due to its unique characteristics, the Haolai River is of interest to researchers and conservationists. Efforts are ongoing to monitor its ecological health and preserve the surrounding grassland environment, which is part of a larger initiative to protect China’s semi-arid ecosystems from degradation.

— From [this June 2025 revision](https://en.wikipedia.org/wiki/Special%3ADiff/1295362066 "Special:Diff/1295362066") to [Haolai River](https://en.wikipedia.org/wiki/Haolai_River "Haolai River")

> The Kwararafa (Kororofa) confederacy is described in scholarship as a shifting [Benue valley](https://en.wikipedia.org/wiki/Benue_valley "Benue valley") coalition led by [Jukun](https://en.wikipedia.org/wiki/Jukun "Jukun") groups and incorporating a range of [Middle Belt](https://en.wikipedia.org/wiki/Middle_Belt "Middle Belt") peoples. Because much of the historical record derives from [Hausa](https://en.wikipedia.org/wiki/Hausa "Hausa") chronicles, Bornu sources and oral tradition, modern researchers treat Kwararafa as a fluid political and cultural formation rather than a fixed state.

— From [this November 2025 revision](https://en.wikipedia.org/wiki/Special%3ADiff/1323819205 "Special:Diff/1323819205") to [Kwararafa Confederacy](https://en.wikipedia.org/wiki/Kwararafa_Confederacy "Kwararafa Confederacy")

AI chatbots also commonly exaggerate the quantity of sources that these opinions are attributed to. They may present views from one or two sources as widely held (often combined with the vague attributions above), mention the existence or opinion of multiple "reviewers" or "scholars" while only citing one person, or imply that lists of examples are non-exhaustive when the sources give no indication that other examples exist.

**Examples**

> While Pakistan was not directly named, the reference to cross-border terrorism, according to Indian sources, was widely interpreted as aimed at Islamabad.[[overgen 1]](https://en.wikipedia.org/wiki/Wikipedia%3ASigns_of_AI_writing#cite_note-Indian_Express-17)

— From [this July 2025 revision](https://en.wikipedia.org/wiki/Special%3ADiff/1299755238 "Special:Diff/1299755238") to [BRICS](https://en.wikipedia.org/wiki/BRICS "BRICS")

> Toy industry publications such as *The Toy Insider* and *Mojo Nation* have presented Rubik's WOWCube as a STEM-oriented platform that brings the Rubik's Cube "into the future" with motion controls and an open software ecosystem.[[overgen 2]](https://en.wikipedia.org/wiki/Wikipedia%3ASigns_of_AI_writing#cite_note-ToyInsider2025-18)[[overgen 3]](https://en.wikipedia.org/wiki/Wikipedia%3ASigns_of_AI_writing#cite_note-Mojo2025-19)

— From [this December 2025 revision](https://en.wikipedia.org/wiki/Special%3ADiff/1325377957 "Special:Diff/1325377957") to [Rubik's WOWCube](https://en.wikipedia.org/wiki/Rubik%27s_WOWCube "Rubik's WOWCube").

References

1. [↑](https://en.wikipedia.org/wiki/Wikipedia%3ASigns_of_AI_writing#cite_ref-Indian_Express_17-0) ["BRICS leaders condemn April 22 Pahalgam attack: On terror, zero tolerance"](https://indianexpress.com/article/india/brics-leaders-condemn-jk-pahalgam-attack-on-terror-zero-tolerance-10110505/). *The Indian Express*. July 7, 2025. Retrieved July 10, 2025.
2. [↑](https://en.wikipedia.org/wiki/Wikipedia%3ASigns_of_AI_writing#cite_ref-ToyInsider2025_18-0) ["Rubik's WOWCube"](https://thetoyinsider.com/products/rubiks-wow-cube/). *The Toy Insider*. October 31, 2025. Retrieved December 2, 2025.
3. [↑](https://en.wikipedia.org/wiki/Wikipedia%3ASigns_of_AI_writing#cite_ref-Mojo2025_19-0) ["Cubios Inc teams with Spin Master for Rubik's WOWCube gaming platform"](https://www.mojo-nation.com/cubios-inc-teams-with-spin-master-for-rubiks-wowcube-gaming-platform/). *Mojo Nation*. July 26, 2025. Retrieved December 2, 2025.

### Outline-like conclusions about challenges and future prospects

|  |  |
| --- | --- |
|  | Words to watch: ***Despite its... faces several challenges...*, *Despite these challenges*, *Challenges and Legacy*, *Future Outlook* ...** |

Many LLM-generated Wikipedia articles include a "Challenges" section, which typically begins with a sentence like "Despite its [positive/promotional words], [article subject] faces challenges..." and ends with either a vaguely positive assessment of the article subject,[[1]](https://en.wikipedia.org/wiki/Wikipedia%3ASigns_of_AI_writing#cite_note-Russell-2) or speculation about how ongoing or potential initiatives could benefit the subject. Such paragraphs usually appear at the end of articles with a rigid outline structure, which may also include a separate section for "Future Prospects."

Note: This sign is about the rigid formula, not simply the mention of challenges or challenging.

**Examples**

| From [this December 2023 revision](https://en.wikipedia.org/wiki/Special%3ADiff/1189640895 "Special:Diff/1189640895") to [International economic law](https://en.wikipedia.org/wiki/International_economic_law "International economic law") |
| --- |
| Challenges and Future Directions  As the global economy continues to evolve, international economic law faces new challenges and opportunities. [...] The future of international economic law lies in its ability to adapt to these emerging trends and continue to facilitate a stable and equitable global economic order. |

| From [this January 2024 revision](https://en.wikipedia.org/w/index.php?title=&diff=1201557771&oldid=) to [Hydrocarbon economy](https://en.wikipedia.org/wiki/Hydrocarbon_economy "Hydrocarbon economy") |
| --- |
| The future of hydrocarbon economies faces several challenges, including[...] This section would speculate on potential developments and the changing landscape of global energy. |

| From [this April 2024 revision](https://en.wikipedia.org/w/index.php?title=&diff=1218690551&oldid=) to [Korattur](https://en.wikipedia.org/wiki/Korattur "Korattur") |
| --- |
| Despite its industrial and residential prosperity, Korattur faces challenges typical of urban areas, including[...] With its strategic location and ongoing initiatives, Korattur continues to thrive as an integral part of the Ambattur industrial zone, embodying the synergy between industry and residential living. |

| From [this August 2024 revision](https://en.wikipedia.org/wiki/Special%3ADiff/1241301672 "Special:Diff/1241301672") to [Amu Television](https://en.wikipedia.org/wiki/Amu_Television "Amu Television") |
| --- |
| Operating in the current Afghan media environment presents numerous challenges, including[...] Despite these challenges, Amu TV has managed to continue to provide a vital service to the Afghan population​​. |

| From [this February 2025 revision](https://en.wikipedia.org/wiki/Special%3ADiff/1277706730 "Special:Diff/1277706730") to [Pyroelectricity](https://en.wikipedia.org/wiki/Pyroelectricity "Pyroelectricity") |
| --- |
| Despite their promising applications, pyroelectric materials face several challenges that must be addressed for broader adoption. One key limitation is[...] Despite these challenges, the versatility of pyroelectric materials positions them as critical components for sustainable energy solutions and next-generation sensor technologies. |

| From [this March 2025 revision](https://en.wikipedia.org/w/index.php?title=&diff=1279428086&oldid=) to [Panama Canal](https://en.wikipedia.org/wiki/Panama_Canal "Panama Canal") |
| --- |
| Despite its success, the Panama Canal faces challenges, including[...] Future investments in technology, such as automated navigation systems, and potential further expansions could enhance the canal’s efficiency and maintain its relevance in global trade. |

| From [this June 2025 revision](https://en.wikipedia.org/wiki/Special%3ADiff/1297629115 "Special:Diff/1297629115") to [Draft:Socio-cognitive engineering](https://en.wikipedia.org/wiki/Wikipedia%3ASigns_of_AI_writing/Examples/Socio-cognitive_engineering "Wikipedia:Signs of AI writing/Examples/Socio-cognitive engineering") |
| --- |
| For example, while the methodology supports transdisciplinary collaboration in principle, applying it effectively in large, heterogeneous teams can be challenging. [...]  SCE continues to evolve in response to these challenges. |

| From [this July 2026 revision](https://en.wikipedia.org/wiki/Special%3ADiff/1363932615 "Special:Diff/1363932615") to [Draft:Spanish fashion](https://en.wikipedia.org/wiki/Draft%3ASpanish_fashion "Draft:Spanish fashion") |
| --- |
| Sociology, sustainability, and future challenges  The main contemporary challenge facing the fashion industry in Spain is its environmental impact, stemming from the production volume of fast fashion. [...]  Complementing this, the sector relies on technological research centres, such as the Textile Technology Institute (Aitex) in the Valencian Community, to develop patents for fibre-to-fibre chemical recycling, eco-design processes, and low-water-impact dyeing. These advancements aim to reduce dependence on petroleum-derived synthetic fibres and virgin cotton, marking the sector's mandatory transition towards sustainable and traceable business models for the coming decades. |

### Leads treating Wikipedia lists or broad article titles as proper nouns

In AI-generated articles about topics with a title that is not a [proper name](https://en.wikipedia.org/wiki/Proper_name "Proper name"), such as a [list](https://en.wikipedia.org/wiki/Wikipedia%3AManual_of_Style/Lists "Wikipedia:Manual of Style/Lists"), the first sentence of the lead may introduce or define the article's title as if it were a standalone real-world entity. While the [MOS](https://en.wikipedia.org/wiki/Wikipedia%3AManual_of_Style/Lead_section#Format_of_the_first_sentence "Wikipedia:Manual of Style/Lead section") does allow such titles to be included at the beginning of the lead "in a natural way", these AI leads tend not to be so natural.

**Examples**

> **Catchment area (health)** refers to the geographic area from which a health facility, such as a hospital or clinic, draws its patients.

— From [this October 2024 revision](https://en.wikipedia.org/wiki/Special%3ADiff/1248996099 "Special:Diff/1248996099") to now-deleted article Catchment area (health)

> EuroGames editions is the chronological list of the biennial EuroGames, a European LGBT+ multi-sport event organized by the European Gay and Lesbian Sport Federation (EGLSF).

— From [this July 2025 revision](https://en.wikipedia.org/wiki/Special%3ADiff/1299100685 "Special:Diff/1299100685") to [EuroGames editions](https://en.wikipedia.org/wiki/EuroGames_editions "EuroGames editions")

> The “**List of songs about Mexico**” is a curated compilation of musical works that reference Mexico its culture, geography, or identity as a central theme.

— From [this July 2025 revision](https://en.wikipedia.org/wiki/Special%3ADiff/1300476090 "Special:Diff/1300476090") to [List of songs about Mexico](https://en.wikipedia.org/wiki/List_of_songs_about_Mexico "List of songs about Mexico")

## Language and grammar

AI-generated text displays consistent patterns in syntax, word choice, and sentence construction that human writing does not display to nearly the same degree. Conversely, it often struggles to match some syntactic and linguistic patterns characteristic of human writing. Some LLMs deviate more from human writing than others; for example, GPT-4o, the language model used by ChatGPT from May 2024 to August 2025, produces output with more variation from human writing than other contemporaneous language models.[[12]](https://en.wikipedia.org/wiki/Wikipedia%3ASigns_of_AI_writing#cite_note-Reinhart-14) Since these are linguistic patterns, they occur consistently regardless of the subject matter, which often gives AI-generated text an identifiable "voice".

### High density of "AI vocabulary" words

[Shortcuts](https://en.wikipedia.org/wiki/Wikipedia%3AShortcut "Wikipedia:Shortcut")

* [WP:AIVOCAB](https://en.wikipedia.org/w/index.php?title=Wikipedia:AIVOCAB&redirect=no)[WP:AIVOCAB](https://en.wikipedia.org/wiki/Wikipedia%3AAIVOCAB "Wikipedia:AIVOCAB")
* [WP:AIWORDS](https://en.wikipedia.org/w/index.php?title=Wikipedia:AIWORDS&redirect=no)[WP:AIWORDS](https://en.wikipedia.org/wiki/Wikipedia%3AAIWORDS "Wikipedia:AIWORDS")

|  |  |
| --- | --- |
|  | Words to watch: ***Additionally* (especially beginning a sentence),[[15]](https://en.wikipedia.org/wiki/Wikipedia%3ASigns_of_AI_writing#cite_note-geng-20)[[16]](https://en.wikipedia.org/wiki/Wikipedia%3ASigns_of_AI_writing#cite_note-huang-21) *align with*,[[11]](https://en.wikipedia.org/wiki/Wikipedia%3ASigns_of_AI_writing#cite_note-Juzek-13)[[17]](https://en.wikipedia.org/wiki/Wikipedia%3ASigns_of_AI_writing#cite_note-Kobak-22) *boasts* (meaning "has"),[[18]](https://en.wikipedia.org/wiki/Wikipedia%3ASigns_of_AI_writing#cite_note-Juzek2-23) *bolstered*,[[17]](https://en.wikipedia.org/wiki/Wikipedia%3ASigns_of_AI_writing#cite_note-Kobak-22) *crucial*,[[1]](https://en.wikipedia.org/wiki/Wikipedia%3ASigns_of_AI_writing#cite_note-Russell-2)[[15]](https://en.wikipedia.org/wiki/Wikipedia%3ASigns_of_AI_writing#cite_note-geng-20)[[16]](https://en.wikipedia.org/wiki/Wikipedia%3ASigns_of_AI_writing#cite_note-huang-21) *delve*,[[11]](https://en.wikipedia.org/wiki/Wikipedia%3ASigns_of_AI_writing#cite_note-Juzek-13)[[17]](https://en.wikipedia.org/wiki/Wikipedia%3ASigns_of_AI_writing#cite_note-Kobak-22)[[1]](https://en.wikipedia.org/wiki/Wikipedia%3ASigns_of_AI_writing#cite_note-Russell-2)[[19]](https://en.wikipedia.org/wiki/Wikipedia%3ASigns_of_AI_writing#cite_note-Kriss-24) *emphasizing*,[[11]](https://en.wikipedia.org/wiki/Wikipedia%3ASigns_of_AI_writing#cite_note-Juzek-13)[[17]](https://en.wikipedia.org/wiki/Wikipedia%3ASigns_of_AI_writing#cite_note-Kobak-22) *enduring*,[[17]](https://en.wikipedia.org/wiki/Wikipedia%3ASigns_of_AI_writing#cite_note-Kobak-22) *enhance*,[[17]](https://en.wikipedia.org/wiki/Wikipedia%3ASigns_of_AI_writing#cite_note-Kobak-22)[[1]](https://en.wikipedia.org/wiki/Wikipedia%3ASigns_of_AI_writing#cite_note-Russell-2) *fostering*,[[17]](https://en.wikipedia.org/wiki/Wikipedia%3ASigns_of_AI_writing#cite_note-Kobak-22)[[1]](https://en.wikipedia.org/wiki/Wikipedia%3ASigns_of_AI_writing#cite_note-Russell-2) *garner*,[[11]](https://en.wikipedia.org/wiki/Wikipedia%3ASigns_of_AI_writing#cite_note-Juzek-13)[[17]](https://en.wikipedia.org/wiki/Wikipedia%3ASigns_of_AI_writing#cite_note-Kobak-22) *highlight* (as a verb),[[1]](https://en.wikipedia.org/wiki/Wikipedia%3ASigns_of_AI_writing#cite_note-Russell-2)[[19]](https://en.wikipedia.org/wiki/Wikipedia%3ASigns_of_AI_writing#cite_note-Kriss-24) *interplay*,[[17]](https://en.wikipedia.org/wiki/Wikipedia%3ASigns_of_AI_writing#cite_note-Kobak-22) *intricate/intricacies*,[[11]](https://en.wikipedia.org/wiki/Wikipedia%3ASigns_of_AI_writing#cite_note-Juzek-13)[[17]](https://en.wikipedia.org/wiki/Wikipedia%3ASigns_of_AI_writing#cite_note-Kobak-22)[[12]](https://en.wikipedia.org/wiki/Wikipedia%3ASigns_of_AI_writing#cite_note-Reinhart-14)[[19]](https://en.wikipedia.org/wiki/Wikipedia%3ASigns_of_AI_writing#cite_note-Kriss-24) *key* (as an adjective),[*[citation needed](https://en.wikipedia.org/wiki/Wikipedia%3ACitation_needed "Wikipedia:Citation needed")*] *landscape* (as an abstract noun),[[1]](https://en.wikipedia.org/wiki/Wikipedia%3ASigns_of_AI_writing#cite_note-Russell-2) *meticulous/meticulously*,[[18]](https://en.wikipedia.org/wiki/Wikipedia%3ASigns_of_AI_writing#cite_note-Juzek2-23)[[17]](https://en.wikipedia.org/wiki/Wikipedia%3ASigns_of_AI_writing#cite_note-Kobak-22) *pivotal*,[[17]](https://en.wikipedia.org/wiki/Wikipedia%3ASigns_of_AI_writing#cite_note-Kobak-22)[[1]](https://en.wikipedia.org/wiki/Wikipedia%3ASigns_of_AI_writing#cite_note-Russell-2) *robust*, *showcase*,[[11]](https://en.wikipedia.org/wiki/Wikipedia%3ASigns_of_AI_writing#cite_note-Juzek-13)[[17]](https://en.wikipedia.org/wiki/Wikipedia%3ASigns_of_AI_writing#cite_note-Kobak-22)[[19]](https://en.wikipedia.org/wiki/Wikipedia%3ASigns_of_AI_writing#cite_note-Kriss-24) *tapestry* (as an abstract noun),[[1]](https://en.wikipedia.org/wiki/Wikipedia%3ASigns_of_AI_writing#cite_note-Russell-2)[[12]](https://en.wikipedia.org/wiki/Wikipedia%3ASigns_of_AI_writing#cite_note-Reinhart-14)[[19]](https://en.wikipedia.org/wiki/Wikipedia%3ASigns_of_AI_writing#cite_note-Kriss-24) *testament*,[[1]](https://en.wikipedia.org/wiki/Wikipedia%3ASigns_of_AI_writing#cite_note-Russell-2) *underscore* (as a verb),[[11]](https://en.wikipedia.org/wiki/Wikipedia%3ASigns_of_AI_writing#cite_note-Juzek-13)[[17]](https://en.wikipedia.org/wiki/Wikipedia%3ASigns_of_AI_writing#cite_note-Kobak-22)[[1]](https://en.wikipedia.org/wiki/Wikipedia%3ASigns_of_AI_writing#cite_note-Russell-2)[[19]](https://en.wikipedia.org/wiki/Wikipedia%3ASigns_of_AI_writing#cite_note-Kriss-24) *valuable*,[[15]](https://en.wikipedia.org/wiki/Wikipedia%3ASigns_of_AI_writing#cite_note-geng-20) *vibrant*[[12]](https://en.wikipedia.org/wiki/Wikipedia%3ASigns_of_AI_writing#cite_note-Reinhart-14)** |

Many studies have demonstrated that LLMs overuse specific words. These words started appearing far more frequently in text produced after 2022, when LLM chatbots became widely accessible.[[11]](https://en.wikipedia.org/wiki/Wikipedia%3ASigns_of_AI_writing#cite_note-Juzek-13)[[17]](https://en.wikipedia.org/wiki/Wikipedia%3ASigns_of_AI_writing#cite_note-Kobak-22) They often co-occur in LLM output: where there is one, there are likely others.[[20]](https://en.wikipedia.org/wiki/Wikipedia%3ASigns_of_AI_writing#cite_note-Kousha-25) While most of these studies have analyzed scientific abstracts or fiction, "AI vocabulary" words are also ubiquitous in LLM-based encyclopedias, such as [Grokipedia](https://en.wikipedia.org/wiki/Grokipedia "Grokipedia"), and in AI-generated Wikipedia text. One or two of these words appearing in an edit may be coincidental, but an edit (post-2022) introducing lots of them, lots of times, is one of the strongest tells for AI use.

The words that LLMs overuse have changed over time. For instance, the word *[delve](https://en.wiktionary.org/wiki/delve "wikt:delve")* was famously overused by ChatGPT in 2023 and early 2024, but became less frequent later in 2024, then dropped off sharply in 2025.[[21]](https://en.wikipedia.org/wiki/Wikipedia%3ASigns_of_AI_writing#cite_note-merrill-26)[[15]](https://en.wikipedia.org/wiki/Wikipedia%3ASigns_of_AI_writing#cite_note-geng-20) Below is a breakdown of which words frequently recur together during which LLM "era". While these are not hard cutoffs, they should give you a rough idea of how "earlier" vs "later" LLM output reads.

* **2023 to mid-2024** (GPT-4): *Additionally*, *boasts*, *bolstered*, *crucial*, *delve*, *emphasizing*, *enduring*, *garner*, *intricate/intricacies*, *interplay*, *key*, *landscape*, *meticulous/meticulously*, *pivotal*, *underscore*, *tapestry*, *testament*, *valuable*, *vibrant*
* **Mid-2024 to mid-2025** (GPT-4o): *align with*, *bolstered*, *crucial*, *emphasizing*, *enhance*, *enduring*, *fostering*, *highlighting*, *pivotal*, *showcasing*, *underscore*, *vibrant*
* **Mid-2025 and on** (GPT-5): *emphasizing*, *enhance*, *highlighting*, *showcasing* (plus words associated with ["Undue emphasis on notability, attribution, and media coverage"](https://en.wikipedia.org/wiki/Wikipedia%3ASigns_of_AI_writing#Undue_emphasis_on_notability,_attribution,_and_media_coverage))

The distribution of "AI vocabulary" is also somewhat different depending on the chatbot or LLM used.[[12]](https://en.wikipedia.org/wiki/Wikipedia%3ASigns_of_AI_writing#cite_note-Reinhart-14) Grok output is particularly idiosyncratic: it overuses superficially "scientific" words like *causal*, *empirical*, *correlate*, and continues to overuse *underscore* as of 2026.

This section is to be taken as literally as possible: a word being overused by AI does *not* imply that its synonyms are also overused. Also, keep context in mind. For example, while the figurative use of "underscore" is ubiquitous in earlier AI text, the word can also refer to a literal underline mark or to [incidental music](https://en.wikipedia.org/wiki/Incidental_music "Incidental music").

**Examples**

| From [this December 2024 revision](https://en.wikipedia.org/wiki/Special%3ADiff/1263234661 "Special:Diff/1263234661") to [Jameh Mosque of Ashtarjan](https://en.wikipedia.org/wiki/Jameh_Mosque_of_Ashtarjan "Jameh Mosque of Ashtarjan"), which contains text pasted from [this revision](https://en.wikipedia.org/wiki/Special%3ADiff/1263233100 "Special:Diff/1263233100") to [User:Hodaalamri/Jameh Mosque of Ashtarjan](https://en.wikipedia.org/wiki/User%3AHodaalamri/Jameh_Mosque_of_Ashtarjan "User:Hodaalamri/Jameh Mosque of Ashtarjan") |
| --- |
| The inscriptions also offer valuable insights into the construction of the mosque. They record the names of the key craftsmen involved, including Mason Ahmad b. Muhammad, known as Haddad (the smith or iron-worker), and Hjajji Muhammad, the tile-cutter from [Tabriz](https://en.wikipedia.org/wiki/Tabriz "Tabriz"). These names highlight the collaborative nature of mosque construction and emphasize the contributions of skilled artisans. [...] For example, the repeated invocation of the names of Muhammad and the Twelve Imams in Kufic script highlights the Shi'ite character of the mosque and links its construction to the broader context of the Ilkhanid state's official adoption of Shi'ism under [Oljeitu](https://en.wikipedia.org/wiki/%C3%96ljait%C3%BC "Öljaitü"). [...] This inscription, commissioned during the reign of the Aq Qoyunlu ruler Uzun Hasan, also underscores the enduring practice of pious patronage for mosque upkeep and renovation. |

| From [this May 2025 revision](https://en.wikipedia.org/wiki/Special%3ADiff/1292567688 "Special:Diff/1292567688") to [Somali people](https://en.wikipedia.org/wiki/Somali_people "Somali people") |
| --- |
| Somali cuisine is an intricate and diverse fusion of a multitude of culinary influences, drawing from the rich tapestry of [Arab](https://en.wikipedia.org/wiki/Arab_cuisine "Arab cuisine"), [Indian](https://en.wikipedia.org/wiki/Indian_cuisine "Indian cuisine"), and [Italian](https://en.wikipedia.org/wiki/Italian_cuisine "Italian cuisine") flavours. This culinary tapestry is a direct result of Somalia's longstanding heritage of vibrant trade and bustling commerce. [...]  Additionally, a distinctive feature of Somali culinary tradition is the incorporation of [camel](https://en.wikipedia.org/wiki/Camel "Camel") [meat](https://en.wikipedia.org/wiki/Meat "Meat") and [milk](https://en.wikipedia.org/wiki/Milk "Milk"). They are considered a delicacy and serve as cherished and fundamental elements in the rich tapestry of Somali cuisine. [...]  An enduring testament to the influence of [Italian colonial rule in Somalia](https://en.wikipedia.org/wiki/Italian_Somaliland "Italian Somaliland") is the widespread adoption of [pasta](https://en.wikipedia.org/wiki/Pasta "Pasta") and [lasagne](https://en.wikipedia.org/wiki/Lasagna "Lasagna") in the local culinary landscape, espicially in the south, showcasing how these dishes have integrated into the traditional diet alongside rice. [...]  Additionally, Somali merchants played a pivotal role in the global coffee trade, being one of the first to export coffee beans. |

### Avoidance of basic copulatives ("is"/"are" phrases)

|  |  |
| --- | --- |
|  | Words to watch: ***serves as/stands as/marks/functions as/operates as/represents [a]*, *boasts/features/maintains/offers [a]*, *refers to*** |

LLM-generated text often replaces simple constructions that use [copulas](https://en.wikipedia.org/wiki/Copula_%28linguistics%29 "Copula (linguistics)") such as *is* or *are* with constructions such as *serves as a* or *mark the*. This pattern has been observed in GPT and Gemini models.[[16]](https://en.wikipedia.org/wiki/Wikipedia%3ASigns_of_AI_writing#cite_note-huang-21) One study documented an over 10% decrease in the usage of the words *is* and *are* in academic writing in 2023, with no major changes in their frequency before that.[[22]](https://en.wikipedia.org/wiki/Wikipedia%3ASigns_of_AI_writing#cite_note-geng2-27) Similarly, LLMs prefer to use [marketing](https://en.wikipedia.org/wiki/Wikipedia%3ABUZZ "Wikipedia:BUZZ")-related verbs like *features*, *offers*, and the like to their neutral synonym *has*. (Note: Do not confuse this with *has* used in the [past perfect](https://en.wikipedia.org/wiki/Pluperfect "Pluperfect") form, as in *has been featured*.) Sometimes--especially in more recent AI output--these constructions are more elaborate, e.g., *ventured into politics as a candidate* versus *was a candidate*, or *began his career as* versus *was*.

A similar decline in "is"/"are" constructions has been observed on Wikipedia, especially when controlling for lead paragraphs (which usually follow a formulaic structure of "[article subject] is...]" and thus skew the data).[[16]](https://en.wikipedia.org/wiki/Wikipedia%3ASigns_of_AI_writing#cite_note-huang-21) It is particularly visible in AI copyedits, which will often "improve" text in this way. The study above also demonstrated that when GPT-3.5 was prompted to "Revise the following sentence" in 10,000 abstracts, the words *is* and *are* appeared less often in the revised versions.[[22]](https://en.wikipedia.org/wiki/Wikipedia%3ASigns_of_AI_writing#cite_note-geng2-27)

In lead sentences, LLMs will sometimes avoid *is* by writing *refers to* [as though the article were about the word or term](https://en.wikipedia.org/wiki/Wikipedia%3ASigns_of_AI_writing#Leads_treating_Wikipedia_lists_or_broad_article_titles_as_proper_nouns) instead of the subject directly.

**Examples**

|  |  |  |  |
| --- | --- | --- | --- |
| − | Gallery 825 on [[La Cienega ~~Boulevard]],~~~~which~~~~was~~~~purchased~~~~in~~ ~~1958,~~ ~~is~~ LAAA's exhibition ~~arm~~ for ~~[[contemporary~~ ~~art]]~~. ~~There~~ ~~are~~ ~~four~~ ~~individual~~ ~~gallery~~ spaces[...] | + | Gallery 825 on [[La Cienega Boulevard]] serves as LAAA's exhibition space for contemporary art. The gallery features four separate spaces[...] |

—From [this August 2023 revision](https://en.wikipedia.org/wiki/Special%3ADiff/1168694674 "Special:Diff/1168694674") to [Los Angeles Art Association](https://en.wikipedia.org/wiki/Los_Angeles_Art_Association "Los Angeles Art Association")

|  |  |  |  |
| --- | --- | --- | --- |
| − | It ~~is~~ Malaysia's first ~~[[Malay~~~~language|Malay]]~~~~daily~~ afternoon [[Tabloid ~~(newspaper~~~~format)|Tabloid]]~~ [...] ~~The~~~~''Harian~~~~Metro''~~~~was~~ ~~established~~ ~~in~~ ~~March~~ ~~1991~~ ~~and~~ ~~is~~ the first and oldest Malay-language tabloid [...] | + | It was established in March 1991 as Malaysia's first Malay-language afternoon [[Tabloid journalism|tabloid]] [...] Harian Metro holds the distinction of being the first and oldest Malay-language tabloid [...] |

—From [this November 2024 revision](https://en.wikipedia.org/wiki/Special%3ADiff/1259995938 "Special:Diff/1259995938") to [Harian Metro](https://en.wikipedia.org/wiki/Harian_Metro "Harian Metro")

### Negative parallelisms

[Shortcut](https://en.wikipedia.org/wiki/Wikipedia%3AShortcut "Wikipedia:Shortcut")

* [WP:AIPARALLEL](https://en.wikipedia.org/w/index.php?title=Wikipedia:AIPARALLEL&redirect=no)[WP:AIPARALLEL](https://en.wikipedia.org/wiki/Wikipedia%3AAIPARALLEL "Wikipedia:AIPARALLEL")

See also: [Negative parallelism](https://en.wikipedia.org/wiki/Negative_parallelism "Negative parallelism")

When LLMs describe a subject, their output may seem as though it is clearing up a common misconception, or as though the audience may be reaching an incomplete or incorrect conclusion about that subject. This kind of contrast can come across as trying to retroactively challenge such thinking by pointing out another characteristic that the subject may possess alongside (or in the place of) one or more previously-mentioned characteristics. While it is common among human writers (especially in "common misconceptions" or "myths busted" [listicles](https://en.wikipedia.org/wiki/Listicle "Listicle")), it is stereotypically an "AI sign."

#### Not just X, but also Y

It is common for LLMs to use parallel constructions involving "not", "but", or "however" such as "Not only ... but ..." or "It is not just ..., it's ...".[[23]](https://en.wikipedia.org/wiki/Wikipedia%3ASigns_of_AI_writing#cite_note-28)[[1]](https://en.wikipedia.org/wiki/Wikipedia%3ASigns_of_AI_writing#cite_note-Russell-2)[[21]](https://en.wikipedia.org/wiki/Wikipedia%3ASigns_of_AI_writing#cite_note-merrill-26)

**Examples**

| From [this August 2024 comment](https://en.wikipedia.org/wiki/Talk%3AEric_Dick_%28lawyer%29#c-Scott_free0011-20240824023600-HCDE_Tenure "Talk:Eric Dick (lawyer)") at [Talk:Eric Dick (lawyer)](https://en.wikipedia.org/wiki/Talk%3AEric_Dick_%28lawyer%29 "Talk:Eric Dick (lawyer)") |
| --- |
| In your most recent exchange, you referred to another editor’s comment as "bizarre" and "totally incorrect," following up with an assertion that their viewpoint was "bogus." This choice of language is not only dismissive but also unnecessarily harsh and confrontational. It shuts down the possibility of constructive dialogue and disrespects the effort that others put into contributing to this platform.  This kind of dismissive and confrontational attitude is not new. [...] This remark doesn’t just undermine the editor’s argument; it questions their very right to participate based on how long they’ve been active, which is contrary to the inclusive nature that Wikipedia aims to foster. New contributors should be encouraged, not belittled, and it’s disheartening to see you take such a dismissive stance.  Your sarcastic remark about adding "Eric Dick is a secret Democrat. [citation needed]" to the article further exemplifies this problematic behavior. Rather than engaging in a meaningful discussion, you chose to mock another editor’s argument, which only serves to create a hostile environment. This approach doesn’t help resolve disputes or improve content; it only escalates tensions and discourages productive collaboration.  Moreover, in another instance, you accused an editor of "bludgeoning discussion with screeds of AI generated waffle" and dismissed their contributions as "acres of fanciful extrapolation on Wikipedia policies." These comments are not just dismissive—they’re outright disrespectful. Accusations like these don’t belong in a professional and collaborative setting. They undermine the very spirit of Wikipedia, which is built on the idea that people with different perspectives can come together to create something valuable.  It’s important to recognize that everyone who contributes to Wikipedia—whether they’re new or experienced, whether they agree with you or not—deserves to be treated with respect. Collaboration, not confrontation, should be the goal. By continuing to engage with others in such a dismissive and harsh manner, you not only discourage participation but also damage the collaborative spirit that is essential to Wikipedia’s success. |

| From [this April 2025 revision](https://en.wikipedia.org/wiki/Special%3ADiff/1288184349 "Special:Diff/1288184349") to [Self-portrait (Yayoi Kusama)](https://en.wikipedia.org/wiki/Self-portrait_%28Yayoi_Kusama%29 "Self-portrait (Yayoi Kusama)") |
| --- |
| **Self-Portrait** by Yayoi Kusama, executed in 2010 and currently preserved in the famous Uffizi Gallery in Florence, constitutes not only a work of self-representation, but a visual document of her obsessions, visual strategies and psychobiographical narratives. |

| From [this August 2025 comment](https://en.wikipedia.org/wiki/Wikipedia%3AArticles_for_deletion/Northern_English_nationalism#c-195.5.161.42-20250827212800-Aszx5000-20250827152200 "Wikipedia:Articles for deletion/Northern English nationalism") at [Wikipedia:Articles for deletion/Northern English nationalism](https://en.wikipedia.org/wiki/Wikipedia%3AArticles_for_deletion/Northern_English_nationalism "Wikipedia:Articles for deletion/Northern English nationalism") |
| --- |
| I appreciate the feedback so far, but I want to clarify something that’s being overlooked. The issue here isn’t just sourcing—it’s framing. There’s a visible, growing movement around Northern English identity, documented across academic literature, social media, and grassroots activism. The fact that it doesn’t always use the exact phrase “Northern English nationalism” doesn’t mean it doesn’t exist. Movements evolve before they’re neatly labelled.  TikTok campaigns, dialect revival, and regional symbolism (like St Oswald’s stripes) are part of a broader cultural shift. Dismissing these as “not notable” or “original research” while allowing pages on Cornish nationalism, Wessex regionalism, and Yorkshire separatism suggests an inconsistency in how regional identity is treated. That’s not just a sourcing issue—it’s a systemic bias. |

Here is an example of a negative parallelism across multiple sentences:

> He hailed from the esteemed Duse family, renowned for their theatrical legacy. Eugenio's life, however, took a path that intertwined both personal ambition and familial complexities.

— From [this April 2025 revision](https://en.wikipedia.org/wiki/Special%3ADiff/1284729136 "Special:Diff/1284729136") to [Eugenio Duse](https://en.wikipedia.org/wiki/Eugenio_Duse "Eugenio Duse")

#### Not X, but Y

Another common LLM pattern is parallelisms that explicitly state that a particular item doesn't possess the first characteristic at all. Such constructions are often expressed as "It's not ..., it's ..." or "no ..., no ..., just ...".[[19]](https://en.wikipedia.org/wiki/Wikipedia%3ASigns_of_AI_writing#cite_note-Kriss-24)

**Examples**

| From [this May 2025 revision](https://en.wikipedia.org/wiki/Special%3ADiff/1288356293 "Special:Diff/1288356293") to [Self-portrait (Yayoi Kusama)](https://en.wikipedia.org/wiki/Self-portrait_%28Yayoi_Kusama%29 "Self-portrait (Yayoi Kusama)") |
| --- |
| The viewer is presented with a self-image that is not grounded in visual mastery, but in what Amelia Jones terms “the performative enactment of subjectivity”.  [...]  This dispersal is not dissolution. Rather, it constitutes what Deleuze might describe as “becoming”—an identity in flux, constituted through iterative difference. Through this lens, Kusama’s self-portrait is not a mirror but a portal: not a representation of self, but a mechanism for its constant reinvention. |

| From [this June 2025 comment](https://en.wikipedia.org/wiki/Wikipedia%3AArticles_for_deletion/Lilly_Contino#c-Momentoftrue-20250617223200-Lilly_Contino "Wikipedia:Articles for deletion/Lilly Contino") at [Wikipedia:Articles for deletion/Lilly Contino](https://en.wikipedia.org/wiki/Wikipedia%3AArticles_for_deletion/Lilly_Contino "Wikipedia:Articles for deletion/Lilly Contino") |
| --- |
| You say these sources “cover multiple events”? False. They echo the same viral incident and do it through a limited lens. This isn’t WP:NBIO — it’s WP:1EVENT in disguise, trying to wear a press badge like armor.  [...]  Now let’s talk BLP1E: This person is only in the news because of one isolated controversy. Not a career, not a body of work, not sustained relevance — just an algorithmic moment. And if we’re really upholding Wikipedia’s values, we don’t preserve pages built on the backs of virality alone, especially when it risks long-term harm to a living subject without lasting notability.  “Might as well get back on topic.”  Then let’s stay on topic, and the topic is not who feels warm fuzzies from visibility, it’s whether this article meets the threshold for inclusion. It doesn’t.  And finally — if you don’t want “a wall of text,” maybe don’t build a wall of shallow logic and expect people not to knock it down. This ain’t bludgeoning — it’s surgical teardown of a weak argument hiding behind fake neutrality. |

#### X rather than Y

This pattern may also be reversed, a construction particularly common in Grok output.

**Examples**

> Chiang's strategy emphasized military suppression of these holdouts to enforce subordination, prioritizing empirical consolidation of power amid fragmented loyalties rather than ideological purity.

— From [this April 2026 revision](https://en.wikipedia.org/wiki/Special%3ADiff/1349156160 "Special:Diff/1349156160") to [First Battle of Guilin](https://en.wikipedia.org/wiki/First_Battle_of_Guilin "First Battle of Guilin"), which explicitly states it is from Grokipedia

### Rule of three

[Shortcut](https://en.wikipedia.org/wiki/Wikipedia%3AShortcut "Wikipedia:Shortcut")

* [WP:RO3](https://en.wikipedia.org/w/index.php?title=Wikipedia:RO3&redirect=no)[WP:RO3](https://en.wikipedia.org/wiki/Wikipedia%3ARO3 "Wikipedia:RO3")

LLMs overuse the [rule of three](https://en.wikipedia.org/wiki/Rule_of_three_%28writing%29 "Rule of three (writing)"). This can take different forms, from "adjective, adjective, adjective" to "short phrase, short phrase, and short phrase".[[1]](https://en.wikipedia.org/wiki/Wikipedia%3ASigns_of_AI_writing#cite_note-Russell-2)[[19]](https://en.wikipedia.org/wiki/Wikipedia%3ASigns_of_AI_writing#cite_note-Kriss-24) LLMs often use this structure to make [superficial analyses](https://en.wikipedia.org/wiki/Wikipedia%3ASigns_of_AI_writing#Superficial_analyses) appear more comprehensive.

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

— From [this July 2024 revision](https://en.wikipedia.org/wiki/Special%3ADiff/1237779206 "Special:Diff/1237779206") to [Rotary saw](https://en.wikipedia.org/wiki/Rotary_saw "Rotary saw") (note that these are [canned-format lists](https://en.wikipedia.org/wiki/Wikipedia%3AAILIST "Wikipedia:AILIST") that used [Markdown](https://en.wikipedia.org/wiki/Wikipedia%3AMARKDOWN "Wikipedia:MARKDOWN"))

### Lexical diversity/elegant variation

For a non-AI-specific style essay about this, see [Wikipedia:The problem with elegant variation](https://en.wikipedia.org/wiki/Wikipedia%3AThe_problem_with_elegant_variation "Wikipedia:The problem with elegant variation").

Further information: [Lexical diversity](https://en.wikipedia.org/wiki/Lexical_diversity "Lexical diversity")

[Shortcut](https://en.wikipedia.org/wiki/Wikipedia%3AShortcut "Wikipedia:Shortcut")

* [WP:AIELEVAR](https://en.wikipedia.org/w/index.php?title=Wikipedia:AIELEVAR&redirect=no)[WP:AIELEVAR](https://en.wikipedia.org/wiki/Wikipedia%3AAIELEVAR "Wikipedia:AIELEVAR")

Generative AI has a repetition-penalty code, meant to discourage it from reusing words too often.[[9]](https://en.wikipedia.org/wiki/Wikipedia%3ASigns_of_AI_writing#cite_note-chronicle-11) This pattern has also been observed on Wikipedia on a broad level: both when comparing Wikipedia text from before 2023 to Wikipedia text from after 2023, and comparing the older Wikipedia text to "Wikipedia-style articles" generated by GPT-4o-mini and Gemini-1.5-Flash.[[16]](https://en.wikipedia.org/wiki/Wikipedia%3ASigns_of_AI_writing#cite_note-huang-21)

Note: If a user adds multiple pieces of AI-generated content in separate edits, this tell may not apply, as each piece of text may have been generated in isolation.

**Examples**

Soviet artistic constraints

Non-conformist artists

Their creativity

> Vierny, after a visit in Moscow in the early 1970’s, committed to supporting artists resisting the constraints of socialist realism and discovered Yankilevskly, among others such as Ilya Kabakov and Erik Bulatov. In the challenging climate of Soviet artistic constraints, Yankilevsky, alongside other non-conformist artists, faced obstacles in expressing their creativity freely. Dina Vierny, recognizing the immense talent and the struggle these artists endured, played a pivotal role in aiding their artistic aspirations. [...]
>
> In this new chapter of his life, Yankilevsky found himself amidst a community of like-minded artists who, despite diverse styles, shared a common goal—to break free from the confines of state-imposed artistic norms, particularly socialist realism. [...]
>
> The move to Paris facilitated an environment where Yankilevsky could further explore and exhibit his distinctive artistic vision without the constraints imposed by the Soviet regime. Dina Vierny's unwavering support and commitment to the Russian avant-garde artists played a crucial role in fostering a space where their creativity could flourish, contributing to the rich tapestry of artistic expression in the vibrant cultural landscape of Paris. Vierny's commitment culminated in the groundbreaking exhibition "Russian Avant-Garde - Moscow 1973" at her Saint-Germain-des-Prés gallery, showcasing the diverse yet united front of non-conformist artists challenging the artistic norms of their time.

— From [this February 2024 revision](https://en.wikipedia.org/wiki/Special%3ADiff/1205035512 "Special:Diff/1205035512") to [Vladimir Yankilevsky](https://en.wikipedia.org/wiki/Vladimir_Yankilevsky "Vladimir Yankilevsky")

It must be noticed however that editors who are not native English speakers might prefer to avoid repeated words as well. For example Italian schools often teach to avoid repeating words.[[24]](https://en.wikipedia.org/wiki/Wikipedia%3ASigns_of_AI_writing#cite_note-birattari2020-29)[[25]](https://en.wikipedia.org/wiki/Wikipedia%3ASigns_of_AI_writing#cite_note-cortelazzo-30)

## Style

### Title case

For non–AI-specific guidance about this, see [Wikipedia:Manual of Style/Capital letters § Headings, headers, and captions](https://en.wikipedia.org/wiki/Wikipedia%3AManual_of_Style/Capital_letters#Headings,_headers,_and_captions "Wikipedia:Manual of Style/Capital letters").

[Shortcut](https://en.wikipedia.org/wiki/Wikipedia%3AShortcut "Wikipedia:Shortcut")

* [WP:AITITLECASE](https://en.wikipedia.org/w/index.php?title=Wikipedia:AITITLECASE&redirect=no)[WP:AITITLECASE](https://en.wikipedia.org/wiki/Wikipedia%3AAITITLECASE "Wikipedia:AITITLECASE")

In section headings, AI chatbots strongly tend to capitalize all main words.[[1]](https://en.wikipedia.org/wiki/Wikipedia%3ASigns_of_AI_writing#cite_note-Russell-2)

**Examples**

> Impact of Technology and Digitalization
>
> The advent of digital technology and the internet has revolutionized international economic law. [...]
>
> Sustainable Development and Environmental Law
>
> The integration of sustainable development goals into international economic law is increasingly important. [...]
>
> Human Rights and Economic Law
>
> The relationship between human rights and international economic law is a growing area of focus. [...]

— From [this December 2023 revision](https://en.wikipedia.org/wiki/Special%3ADiff/1189640895 "Special:Diff/1189640895") to [International economic law](https://en.wikipedia.org/wiki/International_economic_law "International economic law")

### Overuse of boldface

For non-AI-specific guidance about this, see [Wikipedia:Manual of Style/Text formatting § Boldface](https://en.wikipedia.org/wiki/Wikipedia%3AManual_of_Style/Text_formatting#Boldface "Wikipedia:Manual of Style/Text formatting").

[Shortcut](https://en.wikipedia.org/wiki/Wikipedia%3AShortcut "Wikipedia:Shortcut")

* [WP:AIBOLD](https://en.wikipedia.org/w/index.php?title=Wikipedia:AIBOLD&redirect=no)[WP:AIBOLD](https://en.wikipedia.org/wiki/Wikipedia%3AAIBOLD "Wikipedia:AIBOLD")

AI chatbots may display various phrases in [boldface](https://en.wikipedia.org/wiki/Boldface "Boldface") for emphasis in an excessive, mechanical manner. One of their tendencies, inherited from [readmes](https://en.wikipedia.org/wiki/Readme "Readme"), fan wikis, how-tos, sales pitches, slide decks, listicles and other materials that heavily use boldface, is to emphasize every instance of a chosen word or phrase, often in a "key takeaways" fashion. Some newer large language models or apps have instructions to avoid overuse of boldface.

**Examples**

> A **leveraged buyout (LBO)** is characterized by the extensive use of **debt financing** to acquire a company. This financing structure enables **private equity firms** and **financial sponsors** to control businesses while investing a relatively small portion of their own equity. The acquired company’s **assets and future cash flows** serve as collateral for the debt, making lenders more willing to provide financing.

— From [this revision](https://en.wikipedia.org/wiki/Special%3ADiff/1274574473 "Special:Diff/1274574473") to [Leveraged buyout](https://en.wikipedia.org/wiki/Leveraged_buyout "Leveraged buyout")

> **50 Scientists and Thinkers in AI Safety with significant** influence on the field of alignment, containment, and risk mitigation. The list includes their **Productive Years**, their estimated **P(doom)** (probability of existential catastrophe), a **one-sentence summary of their contribution to AI Safety**, and their Wikipedia link.

— From [this revision](https://en.wikipedia.org/wiki/Special%3ADiff/1324781030 "Special:Diff/1324781030") to [P(doom)](https://en.wikipedia.org/wiki/P%28doom%29 "P(doom)")

### Inline-header vertical lists

[Shortcut](https://en.wikipedia.org/wiki/Wikipedia%3AShortcut "Wikipedia:Shortcut")

* [WP:AILIST](https://en.wikipedia.org/w/index.php?title=Wikipedia:AILIST&redirect=no)[WP:AILIST](https://en.wikipedia.org/wiki/Wikipedia%3AAILIST "Wikipedia:AILIST")

For non-AI-specific guidance about this, see [Wikipedia:Manual of Style/Lists § Use prose where understood easily](https://en.wikipedia.org/wiki/Wikipedia%3AManual_of_Style/Lists#Use_prose_where_understood_easily "Wikipedia:Manual of Style/Lists").

AI chatbots output often includes vertical lists formatted in a specific way: an ordered or unordered list where the list marker (number, bullet, dash, etc.) is followed by an inline boldfaced header, separated with a colon from the remaining descriptive text.

Instead of [proper wikitext](https://en.wikipedia.org/wiki/H%3ALIST "H:LIST"), a bullet point in an unordered list may appear as a bullet character (•), hyphen (-), en dash (–), [hash](https://en.wikipedia.org/wiki/Wikipedia%3ASigns_of_AI_writing#Use_of_Markdown) (#), [emoji](https://en.wikipedia.org/wiki/Wikipedia%3ASigns_of_AI_writing#Emoji_as_formatting), or similar character. Ordered lists (i.e. numbered lists) may use explicit numbers (such as `1.`) instead of standard wikitext. When [copied as bare text appearing on the screen](https://en.wikipedia.org/wiki/Wikipedia%3ASCOPY "Wikipedia:SCOPY"), some of the formatting information is lost, and line breaks may be lost as well.

**Examples**

| From [this October 2024 comment](https://en.wikipedia.org/wiki/Wikipedia%3AArticles_for_deletion/Sarwan_Kumar_Bheel#c-IOmParkashSarwanBheel-20241014082300-Saqib-20241014080900 "Wikipedia:Articles for deletion/Sarwan Kumar Bheel") at [Wikipedia:Articles for deletion/Sarwan Kumar Bheel](https://en.wikipedia.org/wiki/Wikipedia%3AArticles_for_deletion/Sarwan_Kumar_Bheel "Wikipedia:Articles for deletion/Sarwan Kumar Bheel") |
| --- |
| Conflict of Interest (COI)/Autobiography: While I understand the concern regarding my username [...]  Notability (GNG and NPOLITICIAN): I have revised the article to focus on factual details [...]  Original Research (WP) and Promotional Tone: I have worked on removing original research [...]  Article Move to Main Namespace: Moving the draft to the main namespace after the AFC review [...] |

| From [this November 2024 revision](https://en.wikipedia.org/wiki/Special%3APermanentLink/1255717748 "Special:PermanentLink/1255717748") to [Sundial (weapon)](https://en.wikipedia.org/wiki/Sundial_%28weapon%29 "Sundial (weapon)") |
| --- |
| 1. Historical Context Post-WWII Era: The world was rapidly changing after WWII, [...] 2. Nuclear Arms Race: Following the U.S. atomic bombings, the Soviet Union detonated its first bomb in 1949, [...] 3. Key Figures Edward Teller: A Hungarian physicist who advocated for the development of more powerful nuclear weapons, [...] 4. Technical Details of Sundial Hydrogen Bomb: The design of Sundial involved a hydrogen bomb [...] 5. Destructive Potential: If detonated, Sundial would create a fireball up to 50 kilometers in diameter, [...] 6. Consequences and Reactions Global Impact: The explosion would lead to an apocalyptic nuclear winter, [...] 7. Political Reactions: The U.S. military and scientists expressed horror at the implications of such a weapon, [...] 8. Modern Implications Current Nuclear Arsenal: Today, there are approximately 12,000 nuclear weapons worldwide, [...] 9. Key Takeaways Understanding the Madness: The concept of Project Sundial highlights the extremes of human ingenuity [...] 10. Questions to Consider What were the motivations behind the development of Project Sundial? [...] |

| From [this October 2025 revision](https://en.wikipedia.org/wiki/Special%3ADiff/1316572059 "Special:Diff/1316572059") to [Draft:AI Visibility Optimization](https://en.wikipedia.org/wiki/Wikipedia%3ASigns_of_AI_writing/Examples/AI_Visibility_Optimization_%28AVO%29 "Wikipedia:Signs of AI writing/Examples/AI Visibility Optimization (AVO)") |
| --- |
| AVO consists of three key layers:   * **SEO (Search Engine Optimization):** Traditional methods for improving visibility in search engine results through content, technical, and on-page optimization. * **AEO (Answer Engine Optimization):** Techniques focused on optimizing content for voice assistants and answer boxes, such as featured snippets and structured data. * **GEO (Generative Engine Optimization):** Strategies for ensuring businesses are cited as credible sources in responses generated by large language models (LLMs). |

| From [this December 2025 revision](https://en.wikipedia.org/wiki/Special%3ADiff/1327088410 "Special:Diff/1327088410") to [Navipet](https://en.wikipedia.org/wiki/Navipet "Navipet") |
| --- |
| Key highlights:   * **Route Details**: Starts at Medak, passes through Yellareddy, Banswada, Nasrullabad, Varni, Rudrur, Bodhan, Shatapur, Navipet, Fakirabad, Basar, Mudhol, and ends at Bhainsa (via Yencha). The Bhainsa-to-Banswada section (Phase 3: Rudrur–Bhainsa, 50+ km) will feature new bypasses to skirt congested towns like Basar and Rudrur, easing traffic and cutting travel time by 20–30%. * **Bypasses and Improvements**: Bypasses are planned at high-density spots (e.g., near Basar temple and Rudrur market), with surveys completed for most sections by mid-2025. This includes elevated corridors over the Manjira River and cotton fields, preserving Navipet's agrarian landscape. * **Timeline and Impact**: Phase 3 (Rudrur–Bhainsa) construction is 40% complete as of December 2025, with full completion targeted for 2027. Once operational, it will slash Hyderabad–Bhainsa travel to under 5 hours and integrate Navipet into a seamless Medak–Adilabad corridor, boosting trade in cotton and turmeric. Local stakeholders hail it as a "lifeline" for farmers, with land acquisition nearly finalized. |

| From [this March 2026 revision](https://en.wikipedia.org/wiki/Special%3ADiff/1345180164 "Special:Diff/1345180164") to [Wikipedia:Requests for page protection/Increase](https://en.wikipedia.org/wiki/Wikipedia%3ARequests_for_page_protection/Increase "Wikipedia:Requests for page protection/Increase") |
| --- |
| Mass Content Removal: The user removed over 20,000 characters of reliably sourced content in a single edit, reducing the number of citations from 34 to 8, without any prior engagement on the Talk page.Disruptive Tagging: Despite the article being supported by 34 high-quality international secondary sources (Wall Street Journal, Bloomberg, Financial Times, etc.), the user implemented excessive "citation needed" tags as a form of visual vandalism to discredit the content.Refusal to engage (WP:BRD): The user was notified of WP:V and WP:DE policies on their talk page but has failed to justify these massive deletions, suggesting a coordinated attempt at de-legitimizing the subject.Context: Given the high-profile nature of the subject in global finance and mining (notably the AstraZeneca/EsoBiotec $1B M&A), the page is currently vulnerable to reputation-based sabotage. |

In some cases, there is no punctuation separating the title of each entry from its corresponding text. This is not to be confused with the way that users sometimes format their !votes in [XfD](https://en.wikipedia.org/wiki/Wikipedia%3AXFD "Wikipedia:XFD") discussions, where words like Keep or Delete are typically written in boldface to set it apart from the arguments for the desired outcome.

**Examples**

| From [this December 2025 comment](https://en.wikipedia.org/wiki/Talk%3AFish_and_chips/Archive_1#Expanding_the_"Origins"_section_to_acknowledge_Portuguese_culinary_technology "Talk:Fish and chips/Archive 1") at [Talk:Fish and chips](https://en.wikipedia.org/wiki/Talk%3AFish_and_chips "Talk:Fish and chips") |
| --- |
| Durability Unlike roasted meats, which become tough and dry, or boiled foods, which rot quickly, battered fish was stable. [...]  Portability and the "Pocket Meal" The structural integrity of the polme made the fish physically durable. [...]  Ruggedness It could be wrapped in a simple cloth or paper and stuffed into a satchel. [...]  One might wonder: if it’s a "travel food," why not just cook it on the ship?  The Fire Hazard Cooking with large quantities of boiling oil on a wooden ship was an invitation to disaster. Open flames were strictly regulated at sea.  The Solution Ships would stock up on large quantities of pre-fried battered fish just before departure. [...]  The Transition After those first 48 hours, the crew would switch to harder-to-prepare staples like dried salt cod (bacalhau) or sea biscuits.  The "Cold" Factor This is the most important part for a "travel-ready" food. [...]  The Dockside "Frying Warehouses" The docks of Lisbon, particularly in the Ribeira (riverside) district, were the epicenter of this technology. [...]  Outdoor Caldrons Professional fryers set up large, permanent iron caldrons over open coal or wood fires right on the quays. [...]  "Deep-Frying Mastery" Because the Portuguese already had the caldrons of hot olive oil ready for their fish, it was a natural technological step to drop potato slices into that same oil. [...]  Street Vendors and "Tabernas" In 16th-century Lisbon, many of the poorer urban residents lived in homes without dedicated kitchens. [...]  The Sephardic "Home Factory" While the docks were the commercial center, the Sephardic Jewish quarters (the Judiarias) were where the technology was refined for domestic safety and religious ritual. [...]  Portuguese Sailors as "Early Adopters" In the 1500s, Portuguese sailors were the most active in the North Atlantic cod trade. [...]  The Iberian Potato "Infrastructure" Potatoes reached the Iberian Peninsula (Lisbon and Seville) c. 1570, nearly two centuries before they were accepted as food in France or the UK. [...]  Linguistic Evidence of Global Export The global reach of Portuguese frying technology is evidenced by its impact on other cultures during the same period [...]  The "Sikbaj" and "Escabeche" Connection The Portuguese technique of Escabeche (which involves frying fish and then preserving it in vinegar) is the maritime "big brother" of the battered fish. [...]  Exports to London 16th-century records show that Portuguese ships weren't just carrying wine and salt; they were heavily laden with olive oil destined for the ports of London, Antwerp, and Amsterdam.  A Taste for the "Foreign" Because Portuguese merchants were so active in London’s docks, they created a local demand for olive oil. [...]  The Later Shift From Olive Oil to "Dripping" As the dish moved from the elite merchant/Jewish circles into the broader British working class during the Industrial Revolution, the oil changed due to cost: [...] |

### Overuse of em dashes

For non-AI-specific guidance about the use of dashes, see [Wikipedia:Manual of Style § Dashes](https://en.wikipedia.org/wiki/Wikipedia%3AManual_of_Style#Dashes "Wikipedia:Manual of Style").

[Shortcut](https://en.wikipedia.org/wiki/Wikipedia%3AShortcut "Wikipedia:Shortcut")

* [WP:AIDASH](https://en.wikipedia.org/w/index.php?title=Wikipedia:AIDASH&redirect=no)[WP:AIDASH](https://en.wikipedia.org/wiki/Wikipedia%3AAIDASH "Wikipedia:AIDASH")

While human editors and writers often use [em dashes](https://en.wikipedia.org/wiki/Em_dash "Em dash") (—), LLM output uses them more often than nonprofessional human-written text of the same genre, and uses them in places where humans are more likely to use commas, parentheses, colons, or (misused) hyphens (-) and [en dashes](https://en.wikipedia.org/wiki/En_dash "En dash") (–). LLMs especially tend to use em dashes in a formulaic, pat way, often mimicking "punched up" sales-like writing by over-emphasizing clauses or parallelisms.[[21]](https://en.wikipedia.org/wiki/Wikipedia%3ASigns_of_AI_writing#cite_note-merrill-26)[[19]](https://en.wikipedia.org/wiki/Wikipedia%3ASigns_of_AI_writing#cite_note-Kriss-24) AI-generated em dashes are usually surrounded by spaces, contrary to common typographic guidelines (which most human users of em dashes will be familiar with).

This sign is most useful when taken in combination with other indicators, not by itself. It is much more common on discussion pages than in article text. Also, because LLMs' use of em-dashes has become somewhat notorious, some AI companies have attempted to make their newer chatbots suppress their use, most notably OpenAI's [GPT-5.1](https://en.wikipedia.org/wiki/GPT-5.1 "GPT-5.1").[[26]](https://en.wikipedia.org/wiki/Wikipedia%3ASigns_of_AI_writing#cite_note-edwards-31)

**Examples**

| From [this April 2025 unblock request](https://en.wikipedia.org/wiki/User_talk%3AApep_the_Serpent_God#c-Apep_the_Serpent_God-20250407133000-April_2025 "User talk:Apep the Serpent God") at [User talk:Apep the Serpent God](https://en.wikipedia.org/wiki/User_talk%3AApep_the_Serpent_God "User talk:Apep the Serpent God") |
| --- |
| I referred to Wikipedia's policies in a discussion with another user, using AI to help me organize my thoughts and better explain the policies I was referencing — something that was reported by the user. [...] If there were any errors in interpretation, they were my own — not mistakes caused by the AI. [...]  [...] Ultimately, one of the admins blocked me — not because of the AI usage itself, which had already been addressed — but because I didn’t respond to their continued questioning. |

| From [this April 2025 revision](https://en.wikipedia.org/w/index.php?title=&diff=1286082047&oldid=) to [Talk:Dutch Caribbean](https://en.wikipedia.org/wiki/Talk%3ADutch_Caribbean "Talk:Dutch Caribbean") |
| --- |
| In practice, many Dutch organizations and businesses use it for **their own convenience**, even placing it in addresses — e.g., “Curaçao, Dutch Caribbean” — but this only **adds confusion** internationally and **erases national identity**. You don’t say **“Netherlands, Europe”** as an address — yet this kind of mislabeling continues. |

| From [this June 2025 comment](https://en.wikipedia.org/wiki/Wikipedia%3AArticles_for_deletion/Lilly_Contino#c-Momentoftrue-20250617193700-Cakelot1-20250617192800 "Wikipedia:Articles for deletion/Lilly Contino") at [Wikipedia:Articles for deletion/Lilly Contino](https://en.wikipedia.org/wiki/Wikipedia%3AArticles_for_deletion/Lilly_Contino "Wikipedia:Articles for deletion/Lilly Contino") |
| --- |
| you're right about one thing — we do seem to have different interpretations of what policy-based discussion entails. [...]  When WP:BLP1E says "one event," it’s shorthand — and the supporting essays, past AfD precedents, and practical enforcement show that “two incidents of fleeting attention” still often fall under the protective scope of BLP1E. This isn’t "imagining" what policy should be — it’s recognizing how community consensus has shaped its application.  Yes, WP:GNG, WP:NOTNEWS, WP:NOTGOSSIP, and the rest of WP:BLP all matter — and I’ve cited or echoed each of them throughout. [...] If a subject lacks enduring, in-depth, independent coverage — and instead rides waves of sensational, short-lived attention — then we’re not talking about encyclopedic significance. [...]  [...] And consensus doesn’t grow from silence — it grows from critique, correction, and clarity.  If we disagree on that, then yes — we’re speaking different languages. |

### Emoji as formatting

[Shortcut](https://en.wikipedia.org/wiki/Wikipedia%3AShortcut "Wikipedia:Shortcut")

* [WP:AIEMOJI](https://en.wikipedia.org/w/index.php?title=Wikipedia:AIEMOJI&redirect=no)[WP:AIEMOJI](https://en.wikipedia.org/wiki/Wikipedia%3AAIEMOJI "Wikipedia:AIEMOJI")

AI chatbots have used [emoji](https://en.wikipedia.org/wiki/Emoji "Emoji") in the past.[[21]](https://en.wikipedia.org/wiki/Wikipedia%3ASigns_of_AI_writing#cite_note-merrill-26)[[15]](https://en.wikipedia.org/wiki/Wikipedia%3ASigns_of_AI_writing#cite_note-geng-20) In particular, they sometimes decorated section headings or bullet points by placing emoji in front of them. These almost always appeared in talk page comments and edit summaries; while they are more rare now, they may still be seen.

**Examples**

| From [this April 2025 revision](https://en.wikipedia.org/wiki/Special%3ADiff/1285703047 "Special:Diff/1285703047") to [User:Bhaskar sunsari](https://en.wikipedia.org/wiki/User%3ABhaskar_sunsari "User:Bhaskar sunsari") |
| --- |
| 👋 Welcome to the User Page of Bhaskar Sunsari  [...]  🧑‍💻 About Me  [...]  🌏 My Interests  Here are some topics I love exploring and contributing to:   * 💻 \*\*Computing & Open Source Technology\*\* * 📚 \*\*Education Systems in South Asia\*\* * 🌄 \*\*Nepalese Culture, History, and Local Stories\*\* * 🔍 \*\*Underrepresented Communities & Forgotten Facts\*\* * 🌐 \*\*Digital Literacy & Tech for Social Good\*\*   🎯 What I’m Working On  [...]  📬 Let’s Connect!  Have a suggestion, correction, or just want to say hi? 👉 Drop me a message [...] I’m always happy to hear from fellow Wikimedians!  🙏 Gratitude |

| From [this May 2025 comment](https://en.wikipedia.org/wiki/Wikipedia%3AVillage_pump_%28policy%29/Archive_202#c-Diamondtier-20250525141800-Diamondtier-20250525141800 "Wikipedia:Village pump (policy)/Archive 202") at [Wikipedia:Village pump (policy)](https://en.wikipedia.org/wiki/Wikipedia%3AVillage_pump_%28policy%29 "Wikipedia:Village pump (policy)") |
| --- |
| Let’s decode exactly what’s happening here:  🧠 Cognitive Dissonance Pattern:  You’ve proven authorship, demonstrated originality, and introduced new frameworks, yet they’re defending a system that explicitly disallows recognition of originators unless a third party writes about them first.  [...]  🧱 Structural Gatekeeping:  Wikipedia policy favors:  [...]  🚨 Underlying Motivation:  Why would a human fight you on this?  [...]  🧭 What You’re Actually Dealing With:  This is not a debate about rules.  [...] |

| From [this July 2025 revision](https://en.wikipedia.org/wiki/Special%3ADiff/1302443439/1303522049 "Special:Diff/1302443439/1303522049") to [History of trigonometry](https://en.wikipedia.org/wiki/History_of_trigonometry "History of trigonometry") |
| --- |
| 🪷 Traditional Sanskrit Name: Trikoṇamiti  Tri = Three  Koṇa = Angle  Miti = Measurement 🧭 “Measurement of three angles” — the ancient Indian art of triangle and angle mathematics.  🕰️ 1. Vedic Era (c. 1200 BCE – 500 BCE)  [...]  🔭 2. Sine of the Bow: Sanskrit Terminology  [...]  🌕 3. Āryabhaṭa (476 CE)  [...]  🌀 4. Varāhamihira (6th Century CE)  [...]  🌠 5. Bhāskarācārya II (12th Century CE)  [...]  📤 Indian Legacy Spreads |

### Unusual use of tables

[Shortcut](https://en.wikipedia.org/wiki/Wikipedia%3AShortcut "Wikipedia:Shortcut")

* [WP:AITABLE](https://en.wikipedia.org/w/index.php?title=Wikipedia:AITABLE&redirect=no)[WP:AITABLE](https://en.wikipedia.org/wiki/Wikipedia%3AAITABLE "Wikipedia:AITABLE")

In rare cases, some AIs may create unnecessary small tables that could be better represented as prose or an [infobox](https://en.wikipedia.org/wiki/Wikipedia%3AINFOBOX "Wikipedia:INFOBOX").

**Examples**

| From [this November 2025 revision](https://en.wikipedia.org/wiki/Special%3ADiff/1323402246 "Special:Diff/1323402246") to [Draft:Biobanks in India](https://en.wikipedia.org/wiki/Wikipedia%3ASigns_of_AI_writing/Examples/Biobanks_in_India "Wikipedia:Signs of AI writing/Examples/Biobanks in India") |
| --- |
| Market and Statistics  The Indian biobanking market was valued at approximately USD 2,101 million in 2024. The sector is expanding to support the "Atmanirbhar Bharat" (Self-reliant India) initiative in healthcare research.   Key Statistics of Indian Biobanking (2024-2025)  | Metric | Figure | | --- | --- | | Market Valuation (2024) | ~USD 2.1 billion | | Major Accredited Facilities | NLDB, CBR Biobank, THSTI, Karkinos | | GenomeIndia Diversity | 99 ethnic groups (32 tribal, 53 non-tribal) | |

| From [this May 2026 revision](https://en.wikipedia.org/wiki/Special%3ADiff/1352783863 "Special:Diff/1352783863") to [Draft:Pacific Mall](https://en.wikipedia.org/wiki/Wikipedia%3ASigns_of_AI_writing/Examples/Pacific_Mall%2C_Tagore_Garden "Wikipedia:Signs of AI writing/Examples/Pacific Mall, Tagore Garden") |
| --- |
| Management  The mall employs approximately 3,167 staff members across all operations. Key management personnel of Pacific Development Corporation Private Limited include:   | Name | Designation | | --- | --- | | S. K. Bansal | Chairman | | Abhishek Bansal | Managing Director | | Saket Bansal | Managing Director | | Mehak Khanna | VP Marketing | |

### Curly quotation marks and apostrophes

For non-AI-specific guidance about this, see [Wikipedia:Manual of Style § Quotation characters](https://en.wikipedia.org/wiki/Wikipedia%3AManual_of_Style#Quotation_characters "Wikipedia:Manual of Style"), and [Wikipedia:Manual of Style § Apostrophes](https://en.wikipedia.org/wiki/Wikipedia%3AManual_of_Style#Apostrophes "Wikipedia:Manual of Style").

[Shortcut](https://en.wikipedia.org/wiki/Wikipedia%3AShortcut "Wikipedia:Shortcut")

* [WP:AICURLY](https://en.wikipedia.org/w/index.php?title=Wikipedia:AICURLY&redirect=no)[WP:AICURLY](https://en.wikipedia.org/wiki/Wikipedia%3AAICURLY "Wikipedia:AICURLY")

ChatGPT and [DeepSeek](https://en.wikipedia.org/wiki/DeepSeek "DeepSeek") typically use curly quotation marks (“...” or ‘...’) instead of straight quotation marks ("..." or '...'). In some cases, AI chatbots inconsistently use pairs of curly and straight quotation marks in the same response. They also tend to use the curly apostrophe (’), the same character as the curly [right single quotation mark](https://en.wikipedia.org/wiki/Right_single_quotation_mark "Right single quotation mark"), instead of the straight apostrophe ('), such as in [contractions](https://en.wikipedia.org/wiki/Contraction_%28grammar%29 "Contraction (grammar)") and [possessive forms](https://en.wikipedia.org/wiki/English_possessive "English possessive"). They may also do this inconsistently.

Curly quotes alone do not prove LLM use. Directional quotation marks (curly or typographer) are often used in published works written and edited using the [Chicago Manual of Style](https://en.wikipedia.org/wiki/Chicago_Manual_of_Style "Chicago Manual of Style").[[27]](https://en.wikipedia.org/wiki/Wikipedia%3ASigns_of_AI_writing#cite_note-32) [Microsoft Word](https://en.wikipedia.org/wiki/Microsoft_Word "Microsoft Word") has a "[smart quotes](https://en.wikipedia.org/wiki/Smart_quotes "Smart quotes")" feature that converts straight quotes to curly quotes. So does the default system-wide configuration on [macOS](https://en.wikipedia.org/wiki/MacOS "MacOS") and [iOS](https://en.wikipedia.org/wiki/IOS "IOS") devices, except on some applications (or if turned off, as may be necessary for [programming](https://en.wikipedia.org/wiki/Computer_programming "Computer programming")). Grammar correcting tools such as [LanguageTool](https://en.wikipedia.org/wiki/LanguageTool "LanguageTool") may also have such a feature.  Curly quotation marks and apostrophes are common in professionally typeset works such as major newspapers. Citation tools like [Citer](https://citer.toolforge.org/) may repeat those that appear in the title of a web page: for example,

> McClelland, Mac (2017-09-27). ["When ‘Not Guilty’ Is a Life Sentence"](https://www.nytimes.com/2017/09/27/magazine/when-not-guilty-is-a-life-sentence.html). *The New York Times*. Retrieved 2025-08-03.

Note that Wikipedia allows users to [customize](https://en.wikipedia.org/wiki/Wikipedia%3ACUSTOM "Wikipedia:CUSTOM") the fonts used to display text. Some fonts display matched curly apostrophes as straight, in which case the distinction is invisible to the user. Additionally, [Gemini](https://en.wikipedia.org/wiki/Gemini_%28language_model%29 "Gemini (language model)") and [Claude](https://en.wikipedia.org/wiki/Claude_%28language_model%29 "Claude (language model)") models typically do not use curly quotes.

### Skipping heading levels

AI chatbots tend to skip level 2 headings (`==`) and start sections from the third level (`===`). [Because doing so is against Wikipedia's accessibility and style conventions](https://en.wikipedia.org/wiki/Wikipedia%3AManual_of_Style/Accessibility#Headings "Wikipedia:Manual of Style/Accessibility"), it is therefore very unlikely for a manually-formatted page to have this quirk.

### Thematic breaks before headings

AI chatbots sometimes include a thematic break (`----`) before each heading in a text (this is common in Markdown output).

**Examples**

```
=== Distinction from French “''[[List of English words of French origin|chiffon]]''” ===
Some claims have suggested that ''Ichafu'' derives from the French word chiffon (“rag” or "light cloth”). However, early lexicographic records do not support this interpretation and later sources differ in their explanations.

[...]
----

== History ==
Headwrapping practices among Igbo women are documented in historical and ethnographic sources and are generally understood to predate the colonial period.

[...]
----

== Form and construction ==
```

— From [this revision](https://en.wikipedia.org/wiki/Special%3ADiff/1344638960 "Special:Diff/1344638960") to [Draft:Ichafu](https://en.wikipedia.org/wiki/Wikipedia%3ASigns_of_AI_writing/Examples/Ichafu "Wikipedia:Signs of AI writing/Examples/Ichafu") and [this archived revision](https://web.archive.org/web/20260323205345/https%3A//en.wikipedia.org/wiki/Ichafu_%28headdress%29) to [Ichafu (headdress)](https://en.wikipedia.org/wiki/Ichafu_%28headdress%29?action=edit&redlink=1 "Ichafu (headdress)")

## Communication intended for the user

### Collaborative communication

[Shortcuts](https://en.wikipedia.org/wiki/Wikipedia%3AShortcut "Wikipedia:Shortcut")

* [WP:CERTAINLY](https://en.wikipedia.org/w/index.php?title=Wikipedia:CERTAINLY&redirect=no)[WP:CERTAINLY](https://en.wikipedia.org/wiki/Wikipedia%3ACERTAINLY "Wikipedia:CERTAINLY")
* [WP:COLLABCOMM](https://en.wikipedia.org/w/index.php?title=Wikipedia:COLLABCOMM&redirect=no)[WP:COLLABCOMM](https://en.wikipedia.org/wiki/Wikipedia%3ACOLLABCOMM "Wikipedia:COLLABCOMM")

|  |  |
| --- | --- |
|  | Words to watch: ***I hope this helps*, *Of course!*, *Certainly!*, *You're absolutely right!*, *Would you like...*, *is there anything else*, *let me know*, *more detailed breakdown*, *here is a* ...** |

Editors sometimes paste text from an AI chatbot that was meant as correspondence, prewriting or advice, rather than article content. This may appear in article text or within comments (<-- -->). Chatbots prompted to produce a Wikipedia article or comment may also explicitly state that the text is meant for Wikipedia, and may mention various [policies and guidelines](https://en.wikipedia.org/wiki/Wikipedia%3APG "Wikipedia:PG") in the output—often explicitly specifying that they're *Wikipedia*'s conventions. Often the advice given by an AI chatbot is incorrect, misleading, or in contravention with policies or guidelines.

**Examples**

> In this section, we will discuss the background information related to the topic of the report. This will include a discussion of relevant literature, previous research, and any theoretical frameworks or concepts that underpin the study. The purpose is to provide a comprehensive understanding of the subject matter and to inform the reader about the existing knowledge and gaps in the field.

— From [this August 2023 revision](https://en.wikipedia.org/w/index.php?title=&diff=1172646802&oldid=) to [Metaphysics](https://en.wikipedia.org/wiki/Metaphysics "Metaphysics")

> If you plan to add this information to the "Animal Cruelty Controversy" section of Foshan's Wikipedia page, ensure that the content is presented in a neutral tone, supported by reliable sources, and adheres to Wikipedia's guidelines on verifiability and neutrality.

— From [this March 2025 revision](https://en.wikipedia.org/wiki/Special%3ADiff/1280200320 "Special:Diff/1280200320") to [Foshan](https://en.wikipedia.org/wiki/Foshan "Foshan")

> Here's a template for your wiki user page. You can copy and paste this onto your user page and customize it further.

— From [this May 2025 revision](https://en.wikipedia.org/wiki/Special%3ADiff/1290281175 "Special:Diff/1290281175") to a user page

> Including photos of the forge (as above) and its tools would enrich the article’s section on culture or economy, [...] Visual resources can also highlight Ronco Canavese’s landscape and landmarks. For instance, a map [...] could be added to orient readers geographically. The village’s scenery [...] could be illustrated with an image. Several such photographs are available (e.g., on Wikimedia Commons) that show Ronco’s panoramic view, [...] Historical images, if any exist [...] would also add depth to the article. Additionally, the town’s notable buildings and sites can be visually presented: [...] Including an image of the Santuario di San Besso [...] could further engage readers. By leveraging these visual aids – maps, photographs of natural and cultural sites – the expanded article can provide a richer, more immersive picture of Ronco Canavese.

— From [this May 2025 revision](https://en.wikipedia.org/wiki/Special%3ADiff/1291175393 "Special:Diff/1291175393") to [Ronco Canavese](https://en.wikipedia.org/wiki/Ronco_Canavese "Ronco Canavese")

> ```
> Final important tip: The ~~~~ at the very end is Wikipedia markup that automatically
> ```

— From [this June 2025 revision](https://en.wikipedia.org/w/index.php?title=&diff=1297191187&oldid=) to [Talk:Test automation management tools](https://en.wikipedia.org/wiki/Talk%3ATest_automation_management_tools "Talk:Test automation management tools"); the message also [ends unexpectedly](https://en.wikipedia.org/wiki/Wikipedia%3ASigns_of_AI_writing#Abrupt_cut_offs)

> Delete this section before submission. After pasting the article, convert as many items as possible in the citation list into inline references attached to the exact sentences they support. If a reviewer questions print-era sources, explain that the article relies on identifiable published books, journals and newspapers from the pre-internet period, several of which survive only as scans from original printed copies.

— From [this April 2026 revision](https://en.wikipedia.org/wiki/Special%3ADiff/1348412352 "Special:Diff/1348412352") to [Draft:Gurmukh Singh Jeet](https://en.wikipedia.org/wiki/Draft%3AGurmukh_Singh_Jeet "Draft:Gurmukh Singh Jeet")

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

— From [Draft:Triple Entry Accounting](https://en.wikipedia.org/wiki/Wikipedia%3ASigns_of_AI_writing/Examples/Triple_Entry_Accounting "Wikipedia:Signs of AI writing/Examples/Triple Entry Accounting") in May 2026, incorrectly advising a user with a COI to self-report to COI/N "after submission".

### Knowledge-cutoff disclaimers and speculation about gaps in sources

[Shortcuts](https://en.wikipedia.org/wiki/Wikipedia%3AShortcut "Wikipedia:Shortcut")

* [WP:AICUTOFF](https://en.wikipedia.org/w/index.php?title=Wikipedia:AICUTOFF&redirect=no)[WP:AICUTOFF](https://en.wikipedia.org/wiki/Wikipedia%3AAICUTOFF "Wikipedia:AICUTOFF")
* [WP:AIDISCLAIMER](https://en.wikipedia.org/w/index.php?title=Wikipedia:AIDISCLAIMER&redirect=no)[WP:AIDISCLAIMER](https://en.wikipedia.org/wiki/Wikipedia%3AAIDISCLAIMER "Wikipedia:AIDISCLAIMER")

|  |  |
| --- | --- |
|  | Words to watch: ***as of [date]*,[[c]](https://en.wikipedia.org/wiki/Wikipedia%3ASigns_of_AI_writing#cite_note-33) *Up to my last training update*, *as of my last knowledge update*, *While specific details are limited/scarce...*, *not widely available/documented/disclosed*, *...in the provided/available sources/search results...*, *based on available information* ...** |

A knowledge-cutoff disclaimer is a statement used by an AI chatbot to indicate that the information provided may be incomplete, inaccurate, or outdated.

If an LLM has a fixed [knowledge cutoff](https://en.wikipedia.org/wiki/Knowledge_cutoff "Knowledge cutoff"), such as older large language models like [GPT-3.5](https://en.wikipedia.org/wiki/GPT-3.5 "GPT-3.5") or [GPT-4](https://en.wikipedia.org/wiki/GPT-4 "GPT-4") (usually the model's last training update), it is unable to provide any information on events or developments past that time. Older LLMs would often remind the user about this by outputting a disclaimer that the information in its response is accurate only up to a certain date, and may explicitly mention the knowledge cutoff in doing so.

Newer chatbots with [retrieval-augmented generation](https://en.wikipedia.org/wiki/Retrieval-augmented_generation "Retrieval-augmented generation") may also fail to find sources on a given topic, or to find information within the sources a user provides. In these cases, they may output a statement, similar to a knowledge-cutoff disclaimer, claiming that the information is not publicly available. They may also pair it with text about what that information "likely" may be and why it is significant. This information is entirely [speculative](https://en.wikipedia.org/wiki/Wikipedia%3AOR "Wikipedia:OR") (including the very claim that it's "not documented") and may be based on loosely related topics or completely fabricated. When that unknown information is about an individual's personal life, this disclaimer often claims that the person "maintains a low profile", "keeps personal details private", etc. This is also speculative.

**Examples**

> As of my last knowledge update in January 2022, I don't have specific information about the current status or developments related to the "Chester Mental Health Center" in today's era.

— From [this November 2023 revision](https://en.wikipedia.org/w/index.php?title=&diff=1186779926&oldid=) to [Chester Mental Health Center](https://en.wikipedia.org/wiki/Chester_Mental_Health_Center "Chester Mental Health Center")

> Though the details of these resistance efforts aren't widely documented, they highlight her bravery...

— From [this December 2024 revision](https://en.wikipedia.org/wiki/Special%3ADiff/1261964722 "Special:Diff/1261964722") to [Throwing Curves: Eva Zeisel](https://en.wikipedia.org/wiki/Throwing_Curves%3A_Eva_Zeisel "Throwing Curves: Eva Zeisel")

> While specific information about the fauna of Studniční hora is limited in the provided search results, the mountain likely supports...

— From [this March 2025 revision](https://en.wikipedia.org/wiki/Special%3ADiff/1280231958 "Special:Diff/1280231958") to [Studniční hora](https://en.wikipedia.org/wiki/Studni%C4%8Dn%C3%AD_hora "Studniční hora")

> While specific details about Kumarapediya's history or economy are not extensively documented in readily available sources, ...

— From [this July 2025 revision](https://en.wikipedia.org/wiki/Special%3ADiff/1301052898 "Special:Diff/1301052898") to [Kumarapediya](https://en.wikipedia.org/wiki/Kumarapediya "Kumarapediya")

> Below is a detailed overview based on available information:

— From [Draft:The Good, The Bad, The Dollar Menu 2](https://en.wikipedia.org/wiki/Wikipedia%3ASigns_of_AI_writing/Examples/Knowledge_cutoff_example_1 "Wikipedia:Signs of AI writing/Examples/Knowledge cutoff example 1") (2025)

> As an underground release, detailed lyrics are not widely transcribed on major sites like Genius or AZLyrics, likely due to the artist's limited mainstream exposure. My analysis is based on available track titles, featured artists, public song snippets from streaming platforms (e.g., Spotify, Apple Music, Deezer), and Honcho's overall discography themes. Where lyrics aren't fully accessible, I've inferred common motifs from similar trap tracks and Honcho's style.
> ...For deeper insights, listening to tracks on platforms like Spotify or Deezer is recommended, as lyrics and production details aren't fully documented in public sources.

— From [Draft:Haiti Honcho](https://en.wikipedia.org/wiki/Wikipedia%3ASigns_of_AI_writing/Examples/Haiti_Honcho "Wikipedia:Signs of AI writing/Examples/Haiti Honcho") (2026)

### Phrasal templates and placeholder text

[Shortcut](https://en.wikipedia.org/wiki/Wikipedia%3AShortcut "Wikipedia:Shortcut")

* [WP:AIPLACEHOLDER](https://en.wikipedia.org/w/index.php?title=Wikipedia:AIPLACEHOLDER&redirect=no)[WP:AIPLACEHOLDER](https://en.wikipedia.org/wiki/Wikipedia%3AAIPLACEHOLDER "Wikipedia:AIPLACEHOLDER")

AI chatbots may generate responses with fill-in-the-blank [phrasal templates](https://en.wikipedia.org/wiki/Phrasal_template "Phrasal template") (as seen in the game *[Mad Libs](https://en.wikipedia.org/wiki/Mad_Libs "Mad Libs")*) for the LLM user to replace with words and phrases pertaining to their use case. However, some LLM users forget to fill in those blanks. Note that non-LLM-generated templates exist for drafts and new articles, such as [Wikipedia:Artist biography article template/Preload](https://en.wikipedia.org/wiki/Wikipedia%3AArtist_biography_article_template/Preload "Wikipedia:Artist biography article template/Preload") and pages in [Category:Article creation templates](https://en.wikipedia.org/wiki/Category%3AArticle_creation_templates "Category:Article creation templates").

**Examples**

> I hope this message finds you well. I am writing to request an edit for the Wikipedia entry
>
> I have identified an area within the article that requires updating/improvement. [Describe the specific section or content that needs editing and provide clear reasons why the edit is necessary, including reliable sources if applicable].

— From [this February 2024 revision](https://en.wikipedia.org/wiki/Special%3ADiff/1210511971 "Special:Diff/1210511971") to [Talk:Spaghetti](https://en.wikipedia.org/wiki/Talk%3ASpaghetti "Talk:Spaghetti")

> We remain committed to creating content that aligns with Wikipedia's mission and are open to further guidance. Please find our revised article [link to the revised article] and a detailed list of sources [link to source list]. We hope to resubmit our work once these changes have been made.
>
> Thank you for your understanding and assistance in this matter.
>
> Best regards, [Your Name] and Chloe

— From [this December 2024 revision](https://en.wikipedia.org/wiki/Special%3ADiff/1261926945 "Special:Diff/1261926945") to [Wikipedia:WikiProject Articles for creation/Help desk](https://en.wikipedia.org/wiki/Wikipedia%3AWikiProject_Articles_for_creation/Help_desk "Wikipedia:WikiProject Articles for creation/Help desk")

> I am writing to express my deep concern about the spread of misinformation on your platform. Specifically, I am referring to the article about [Entertainer's Name], which I believe contains inaccurate and harmful information.

— From [this March 2025 revision](https://en.wikipedia.org/wiki/Special%3ADiff/1278589409 "Special:Diff/1278589409") to [Talk:Kjersti Flaa](https://en.wikipedia.org/wiki/Talk%3AKjersti_Flaa "Talk:Kjersti Flaa")

Large language models may also insert placeholder dates like "2025-xx-xx" into citation fields, particularly the access-date parameter and [rarely the date parameter as well](https://en.wikipedia.org/wiki/Special%3APermanentLink/1295449767#References "Special:PermanentLink/1295449767"), producing errors.

**Examples**

| From [this November 2025 revision](https://en.wikipedia.org/wiki/Special%3ADiff/1324292862 "Special:Diff/1324292862") to [Michelle Osis](https://en.wikipedia.org/wiki/Michelle_Osis "Michelle Osis") |
| --- |
| ``` <ref>{{cite web  |title=Canadian Screen Music Awards 2025 Winners and Nominees  |url=URL  |website=Canadian Screen Music Awards  |date=2025  |access-date=2025-XX-XX }}</ref>  <ref>{{cite web  |title=Best Original Score, Dramatic Series or Special – Winner: "Murder on the Inca Trail"  |url=URL  |website=Canadian Screen Music Awards  |date=2025  |access-date=2025-XX-XX }}</ref> ``` |

**Links to searches**

* [insource:/20[0-9][0-9]-(XX|xx)-(XX|xx)/](https://en.wikipedia.org/w/index.php?search=insource%3A%2F20%5B0-9%5D%5B0-9%5D-%28XX%7Cxx%29-%28XX%7Cxx%29%2F&title=Special%3ASearch&profile=advanced&fulltext=1&ns0=1)

In some cases, LLM-generated citations may also contain placeholders in other fields.

**Examples**

| From [this December 2025 revision](https://en.wikipedia.org/wiki/Special%3ADiff/1330090335 "Special:Diff/1330090335") to [Dmitry Kuznetsov (politician)](https://en.wikipedia.org/wiki/Dmitry_Kuznetsov_%28politician%29 "Dmitry Kuznetsov (politician)") |
| --- |
| {{cite web  |url=INSERT\_SOURCE\_URL\_30  |title=Deputy Monitoring of Regional Assistance to Mobilized Soldiers  |date=2022-11-XX  |publisher=SOURCE\_PUBLISHER  |accessdate=2024-07-21 }} |

| From [this February 2026 revision](https://en.wikipedia.org/wiki/Special%3ADiff/1337437306 "Special:Diff/1337437306") to [Nelly Joy](https://en.wikipedia.org/wiki/Nelly_Joy "Nelly Joy") |
| --- |
| <ref>{{cite web  |title=Ecos de Amor – Spotify  |url=PASTE\_SPOTIFY\_TRACK\_URL\_HERE  |website=Spotify  |access-date=2026-02-09 }}</ref> <ref>{{cite web  |title=Jesse & Joy – Ecos de Amor (Official Music Video)  |url=PASTE\_YOUTUBE\_VIDEO\_URL\_HERE  |website=YouTube  |access-date=2026-02-09 }}</ref> |

LLM-generated infobox edits may contain comments stating that text or images should be added if sources are found. Note: Comments in infoboxes, especially older infoboxes, are common—some templates automatically include them—and not an indicator of AI use. Anything but "Add \_\_\_\_", or variations on that specific wording, is actually more likely to indicate human text. Even then, there are exceptions; for example, articles with [Template:Infobox military person](https://en.wikipedia.org/wiki/Template%3AInfobox_military_person "Template:Infobox military person") often contain the boilerplate "Add spouse if reliably sourced", which predates LLMs.

**Examples**

> | leader\_name = <!-- Add if available with citation -->

— From [this July 2025 revision](https://en.wikipedia.org/wiki/Special%3ADiff/1301011748 "Special:Diff/1301011748") to [Pindi Saidpur](https://en.wikipedia.org/wiki/Pindi_Saidpur "Pindi Saidpur")

## Markup

### Use of Markdown

[Shortcuts](https://en.wikipedia.org/wiki/Wikipedia%3AShortcut "Wikipedia:Shortcut")

* [WP:MARKDOWN](https://en.wikipedia.org/w/index.php?title=Wikipedia:MARKDOWN&redirect=no)[WP:MARKDOWN](https://en.wikipedia.org/wiki/Wikipedia%3AMARKDOWN "Wikipedia:MARKDOWN")
* [WP:AIMARKDOWN](https://en.wikipedia.org/w/index.php?title=Wikipedia:AIMARKDOWN&redirect=no)[WP:AIMARKDOWN](https://en.wikipedia.org/wiki/Wikipedia%3AAIMARKDOWN "Wikipedia:AIMARKDOWN")

A lot of AI chatbots are not proficient in [wikitext](https://en.wikipedia.org/wiki/H%3AWT "H:WT"), the [markup language](https://en.wikipedia.org/wiki/Markup_language "Markup language") used to instruct Wikipedia's [MediaWiki](https://en.wikipedia.org/wiki/MediaWiki "MediaWiki") software how to format an article. As wikitext is a niche markup language, found mostly on Wikipedia, other Wikimedia wikis, and other MediaWiki-based platforms like [Miraheze](https://en.wikipedia.org/wiki/Miraheze "Miraheze"), LLMs wikitext-formatted content is not prominent in their training data. While the corpora of chatbots did ingest millions of Wikipedia articles, these articles would not have been processed as text files containing wikitext syntax.

In chatbot apps, the output display is formatted with Markdown, a markup language conceptually similar to wikitext but much more widely applied. Meanwhile, the chatbots' preprompts typically instruct them to use markdown in their answers, such as when providing lists and writing with headings. That is, their system-level instructions often direct them to format outputs using Markdown, and the chatbot apps render its syntax as formatted text on a user's screen. For example, the system prompt for Claude Sonnet 3.5 (November 2024) includes:[[28]](https://en.wikipedia.org/wiki/Wikipedia%3ASigns_of_AI_writing#cite_note-sonnetprompt-34)

> Claude uses Markdown formatting. When using Markdown, Claude always follows best practices for clarity and consistency. It always uses a single space after hash symbols for headers (e.g., "# Header 1") and leaves a blank line before and after headers, lists, and code blocks. For emphasis, Claude uses asterisks or underscores consistently (e.g., italic or bold). When creating lists, it aligns items properly and uses a single space after the list marker. For nested bullets in bullet point lists, Claude uses two spaces before the asterisk (\*) or hyphen (-) for each level of nesting. For nested bullets in numbered lists, Claude uses three spaces before the number and period (e.g., "1.") for each level of nesting.

As the above indicates, Markdown syntax is completely different from wikitext. Markdown uses asterisks (\*) or underscores (\_) instead of single-quotes (') for bold and italic formatting, hash symbols (#) instead of equals signs (=) for section headings, parentheses (()) instead of square brackets ([]) around URLs, and three symbols (---, \*\*\*, or \_\_\_) instead of four hyphens (----) for thematic breaks.

When told to "generate an article", chatbots often default to using Markdown for the generated output. This formatting is preserved in clipboard text by the copy functions on some chatbot platforms. If instructed to generate content for Wikipedia, the chatbot might "realize" the need to generate Wikipedia-compatible code, and might include a message like "Would you like me to ... turn this into actual Wikipedia markup format (`wikitext`)?"[[d]](https://en.wikipedia.org/wiki/Wikipedia%3ASigns_of_AI_writing#cite_note-35) in its output. If the chatbot is told to proceed, the resulting syntax is often rudimentary, syntactically incorrect, or both. The chatbot might put its attempted-wikitext content in a Markdown-style [fenced code block](https://www.markdownguide.org/extended-syntax/#fenced-code-blocks) (its syntax for [WP:PRE](https://en.wikipedia.org/wiki/Wikipedia%3APRE "Wikipedia:PRE")) surrounded by Markdown-based syntax and content, which may also be preserved by platform-specific copy-to-clipboard functions, leading to a telling footprint of both markup languages' syntax. This might include the appearance of three backticks in the text, such as: ```` ```wikitext ````.[[e]](https://en.wikipedia.org/wiki/Wikipedia%3ASigns_of_AI_writing#cite_note-36)[[f]](https://en.wikipedia.org/wiki/Wikipedia%3ASigns_of_AI_writing#cite_note-37)

The presence of faulty wikitext syntax mixed with Markdown syntax is a strong indicator that content is LLM-generated, especially if in the form of a fenced Markdown code block. However, Markdown *alone* is not such a strong indicator. Software developers, researchers, technical writers, and experienced internet users frequently use Markdown in tools like [Obsidian](https://en.wikipedia.org/wiki/Obsidian_%28software%29 "Obsidian (software)") and [GitHub](https://en.wikipedia.org/wiki/GitHub_Flavored_Markdown "GitHub Flavored Markdown"), and on platforms like [Reddit](https://support.reddithelp.com/hc/en-us/articles/360043033952-Formatting-Guide), [Discord](https://support.discord.com/hc/en-us/articles/210298617-Markdown-Text-101-Chat-Formatting-Bold-Italic-Underline), and [Slack](https://slack.com/help/articles/202288908-Format-your-messages). Some writing tools and apps, such as [iOS Notes](https://en.wikipedia.org/wiki/IOS_Notes "IOS Notes"), [Google Docs](https://en.wikipedia.org/wiki/Google_Docs "Google Docs"), and [Windows Notepad](https://en.wikipedia.org/wiki/Windows_Notepad "Windows Notepad"), support Markdown editing or exporting. The increasing ubiquity of Markdown may also lead new editors to expect or assume Wikipedia to support Markdown by default.

**Examples**

See also: [Markdown § Examples](https://en.wikipedia.org/wiki/Markdown#Examples "Markdown")

| From [this April 2025 revision](https://en.wikipedia.org/w/index.php?title=&diff=1284964006&oldid=) to a user talk page |
| --- |
| I believe this block has become procedurally and substantively unsound. Despite repeatedly raising clear, policy-based concerns, every unblock request has been met with \*\*summary rejection\*\* — not based on specific diffs or policy violations, but instead on \*\*speculation about motive\*\*, assertions of being “unhelpful”, and a general impression that I am "not here to build an encyclopedia". No one has meaningfully addressed the fact that I have \*\*not made disruptive edits\*\*, \*\*not engaged in edit warring\*\*, and have consistently tried to \*\*collaborate through talk page discussion\*\*, citing policy and inviting clarification. Instead, I have encountered a pattern of dismissiveness from several administrators, where reasoned concerns about \*\*in-text attribution of partisan or interpretive claims\*\* have been brushed aside. Rather than engaging with my concerns, some editors have chosen to mock, speculate about my motives, or label my arguments "AI-generated" — without explaining how they are substantively flawed. |

| From [this May 2025 revision](https://en.wikipedia.org/w/index.php?title=&diff=1290202502&oldid=) to [Talk:Dana Klisanin](https://en.wikipedia.org/wiki/Talk%3ADana_Klisanin "Talk:Dana Klisanin") |
| --- |
| - The Wikipedia entry does not explicitly mention the "Cyberhero League" being recognized as a winner of the World Future Society's BetaLaunch Technology competition, as detailed in the interview with THE FUTURIST ([https://consciouscreativity.com/the-futurist-interview-with-dana-klisanin-creator-of-the-cyberhero-league/](https://consciouscreativity.com/the-futurist-interview-with-dana-klisanin-creator-of-the-cyberhero-league/)). This recognition could be explicitly stated in the "Game design and media consulting" section. |

As shown below, LLMs incorrectly use `##` to denote section headings, which MediaWiki interprets as a numbered list.

> 1. 1. Geography
>
> Villers-Chief is situated in the [Jura Mountains](https://en.wikipedia.org/wiki/Jura_Mountains "Jura Mountains"), in the eastern part of the Doubs department. [...]
>
> 1. 1. History
>
> Like many communes in the region, Villers-Chief has an agricultural past. [...]
>
> 1. 1. Administration
>
> Villers-Chief is part of the [Canton of Valdahon](https://en.wikipedia.org/wiki/Canton_of_Valdahon "Canton of Valdahon") and the [Arrondissement of Pontarlier](https://en.wikipedia.org/wiki/Arrondissement_of_Pontarlier "Arrondissement of Pontarlier"). [...]
>
> 1. 1. Population
>
> The population of Villers-Chief has seen some fluctuations over the decades, [...]

— From [this June 2025 revision](https://en.wikipedia.org/wiki/Special%3ADiff/1294887075 "Special:Diff/1294887075") to [Villers-Chief](https://en.wikipedia.org/wiki/Villers-Chief "Villers-Chief")

### Broken wikitext

Since AI chatbots are typically not proficient in wikitext and templates, they often produce faulty syntax. A noteworthy instance is garbled code related to [Template:AfC submission](https://en.wikipedia.org/wiki/Template%3AAfC_submission "Template:AfC submission"), as new editors might ask a chatbot how to submit their [Articles for Creation](https://en.wikipedia.org/wiki/Wikipedia%3AArticles_for_Creation "Wikipedia:Articles for Creation") draft; see [this discussion among AfC reviewers](https://en.wikipedia.org/wiki/Special%3APermanentLink/1299830745#Messed_up_templates "Special:PermanentLink/1299830745").

**Examples**

> ```
> [[Category:AfC submissions by date/<0030Fri, 13 Jun 2025 08:18:00 +0000202568 2025-06-13T08:18:00+00:00Fridayam0000=error>EpFri, 13 Jun 2025 08:18:00 +0000UTC00001820256 UTCFri, 13 Jun 2025 08:18:00 +0000Fri, 13 Jun 2025 08:18:00 +00002025Fri, 13 Jun 2025 08:18:00 +0000: 17498026806Fri, 13 Jun 2025 08:18:00 +0000UTC2025-06-13T08:18:00+00:0020258618163UTC13 pu62025-06-13T08:18:00+00:0030uam301820256 2025-06-13T08:18:00+00:0008amFri, 13 Jun 2025 08:18:00 +0000am2025-06-13T08:18:00+00:0030UTCFri, 13 Jun 2025 08:18:00 +0000 &qu202530;:&qu202530;.</0030Fri, 13 Jun 2025 08:18:00 +0000202568>June 2025|sandbox]]
> ```

— From [this revision](https://en.wikipedia.org/wiki/Special%3APermanentLink/1295363321 "Special:PermanentLink/1295363321") to [User:Dr. Omokhudu Idogho/sandbox](https://en.wikipedia.org/wiki/User%3ADr._Omokhudu_Idogho/sandbox "User:Dr. Omokhudu Idogho/sandbox")

### Internal formatting and reference markup bugs

[Shortcut](https://en.wikipedia.org/wiki/Wikipedia%3AShortcut "Wikipedia:Shortcut")

* [WP:OAICITE](https://en.wikipedia.org/w/index.php?title=Wikipedia:OAICITE&redirect=no)[WP:OAICITE](https://en.wikipedia.org/wiki/Wikipedia%3AOAICITE "Wikipedia:OAICITE")

LLM output sometimes exposes its internal formatting code, which is an unambiguous indicator that the text originated with AI. The specific bugs vary by chatbot or tool.

#### ChatGPT: contentReference, oaicite/oai\_citation, +1, turn0search0, attributableIndex

ChatGPT sometimes adds code in the form of `:contentReference[oaicite:0]{index=0}`, `Example+1`, or `oai_citation` in place of links to references in output text.

**Examples**

| From [this June 2025 revision](https://en.wikipedia.org/w/index.php?title=&diff=1294765751&oldid=) to [Talk:Sial (tribe)](https://en.wikipedia.org/wiki/Talk%3ASial_%28tribe%29 "Talk:Sial (tribe)"). |
| --- |
| contentReference[oaicite:16]{index=16}  1. \*\*Ethnicity clarification\*\*   ```   - :contentReference[oaicite:17]{index=17}     * :contentReference[oaicite:18]{index=18} :contentReference[oaicite:19]{index=19}.     * Denzil Ibbetson’s *Panjab Castes* classifies Sial as Rajputs :contentReference[oaicite:20]{index=20}.     * Historian’s blog notes: "The Sial are a clan of Parmara Rajputs…” :contentReference[oaicite:21]{index=21}. ```   2. :contentReference[oaicite:22]{index=22}   ```   - :contentReference[oaicite:23]{index=23}     > :contentReference[oaicite:24]{index=24} :contentReference[oaicite:25]{index=25}. ``` |

| From [this June 2025 revision](https://en.wikipedia.org/w/index.php?title=&diff=1296028135&oldid=) to [Talk:Independent Together](https://en.wikipedia.org/wiki/Talk%3AIndependent_Together "Talk:Independent Together") |
| --- |
| 1. 1. 1. 1. 📌 Key facts needing addition or correction:   1. \*\*Group launch & meetings\*\*   ```    *Independent Together* launched a “Zero Rates Increase Roadshow” on 15 June, with events in Karori, Hataitai, Tawa, and Newtown  [oai_citation:0‡wellington.scoop.co.nz](https://wellington.scoop.co.nz/?p=171473&utm_source=chatgpt.com). ```   2. \*\*Zero-rates pledge and platform\*\*   ```    The group pledges no rates increases for three years, then only match inflation—responding to Wellington’s 16.9% hike for 2024/25  [oai_citation:1‡en.wikipedia.org](https://en.wikipedia.org/wiki/Independent_Together?utm_source=chatgpt.com). ``` |

| From [this November 2025 revision](https://en.wikipedia.org/wiki/Special%3ADiff/1325099471 "Special:Diff/1325099471") to [ISO/IEC 27017](https://en.wikipedia.org/wiki/ISO/IEC_27017 "ISO/IEC 27017") |
| --- |
| This was created conjointly by technical committee ISO/IEC JTC 1/SC 27 (Information security, cybersecurity, and protection of privacy) IT Governance+3ISO+3ISO+3. It belongs to the ISO/IEC 27000 family that talks about information security management systems (ISMS) and related practice controls. Wikipedia+1. The standard gives guidance for information security controls for cloud service providers (CSPs) and cloud service customers (CSCs). Specifically adapted to cloud specific environments like responsibility, virtualization, dynamic provisioning, and multi-tenant infrastructure. Ignyte+3Microsoft Learn+3Google Cloud+3. |

ChatGPT may include `citeturn0search0` (surrounded by Unicode points in the [Private Use Area](https://en.wikipedia.org/wiki/Private_Use_Area "Private Use Area")) at the ends of sentences, with the number after "search" increasing as the text progresses. There also exists an alternate shorter form with only the increasing number surrounded by PUA Unicode like `0`. These are places where the chatbot links to an external site, but a human pasting the conversation into Wikipedia has that link converted into placeholder code. This was first observed in February 2025. Less often, the pattern may appear as a ref name, e.g., <ref name="0search12">.

A set of images in a response may also render as `iturn0image0turn0image1turn0image4turn0image5`. Rarely, other markup of a similar style, such as `citeturn0news0` ([example](https://en.wikipedia.org/wiki/Special%3APermanentLink/1276934509 "Special:PermanentLink/1276934509")), `citeturn1file0` ([example](https://en.wikipedia.org/wiki/Special%3APermanentLink/1286349902 "Special:PermanentLink/1286349902")), or `citegenerated-reference-identifier` ([example](https://en.wikipedia.org/wiki/Special%3APermanentLink/1276907078 "Special:PermanentLink/1276907078")), may appear.

**Examples**

> The school is also a center for the US College Board examinations, SAT I & SAT II, and has been recognized as an International Fellowship Centre by Cambridge International Examinations. citeturn0search1
> For more information, you can visit their official website: citeturn0search0

— From [this February 2025 revision](https://en.wikipedia.org/w/index.php?title=&diff=1274664396&oldid=) to [List of English-medium schools in Bangladesh](https://en.wikipedia.org/wiki/List_of_English-medium_schools_in_Bangladesh "List of English-medium schools in Bangladesh")

> * \*\*Japanese:\*\* Reze is voiced by Reina Ueda, an established voice actress known for roles such as Cha Hae-In in *Solo Leveling* and Kanao Tsuyuri in *Demon Slayer*.2
> * \*\*English:\*\* In the English dub of the anime film, Reze is voiced by Alexis Tipton, noted for her work in series such as *Kaguya-sama: Love is War*.3
>
> [...]
>
> The film itself holds a high rating on \*\*Rotten Tomatoes\*\* and has been described as a major anime release of 2025, indicating strong overall reception for the Reze Arc storyline and its adaptation.5

— From [Draft:Reze (Chainsaw Man)](https://en.wikipedia.org/wiki/Wikipedia%3ASigns_of_AI_writing/Examples/Reze_%28Chainsaw_Man%29 "Wikipedia:Signs of AI writing/Examples/Reze (Chainsaw Man)") (2025)

ChatGPT may add [JSON](https://en.wikipedia.org/wiki/JSON "JSON")-formatted code at the end of sentences in the form of `({"attribution":{"attributableIndex":"X-Y"}})`, with X and Y being increasing numeric indices.

**Examples**

> ^[Evdokimova was born on 6 October 1939 in Osnova, Kharkov Oblast, Ukrainian SSR (now Kharkiv, Ukraine).]({"attribution":{"attributableIndex":"1009-1"}}) ^[She graduated from the Gerasimov Institute of Cinematography (VGIK) in 1963, where she studied under Mikhail Romm.]({"attribution":{"attributableIndex":"1009-2"}}) [oai\_citation:0‡IMDb](<https://www.imdb.com/name/nm0947835/?utm_source=chatgpt.com>) [oai\_citation:1‡maly.ru](<https://www.maly.ru/en/people/EvdokimovaA?utm_source=chatgpt.com>)

— From [Draft:Aleftina Evdokimova](https://en.wikipedia.org/wiki/Wikipedia%3ASigns_of_AI_writing/Examples/Aleftina_Evdokimova "Wikipedia:Signs of AI writing/Examples/Aleftina Evdokimova") (2025)

> Patrick Denice & Jake Rosenfeld, [Les syndicats et la rémunération non syndiquée aux États-Unis, 1977–2015](https://sociologicalscience.com/articles-v5-23-541/), ‘‘Sociological Science’’ (2018).]({“attribution”:{“attributableIndex”:“3795-0”}})

— From [this April 2025 revision](https://fr.wikipedia.org/wiki/Special%3ADiff/225259294 "fr:Special:Diff/225259294") to [fr:Syndicalisme aux États-Unis](https://fr.wikipedia.org/wiki/Syndicalisme%20aux%20%C3%89tats-Unis "fr:Syndicalisme aux États-Unis")

**Links to searches**

* ["contentReference" OR "oaicite" OR "oai\_citation"](https://en.wikipedia.org/w/index.php?search=%22contentReference%22+OR+%22oaicite%22+OR+%22oai_citation%22&title=Special%3ASearch)
* [turn0search0 OR turn0search1 OR turn0search2 OR turn0search3 OR turn0search4 OR turn0search5 OR turn0search6 OR turn0search7](https://en.wikipedia.org/w/index.php?title=Special:Search&search=turn0search0+OR+turn0search1+OR+turn0search2+OR+turn0search3+OR+turn0search4+OR+turn0search5+OR+turn0search6+OR+turn0search7&ns0=1&fulltext=Search)
* [turn0image0 OR turn0image1 OR turn0image2 OR turn0image3 OR turn0image4 OR turn0image5 OR turn0image6 OR turn0image7](https://en.wikipedia.org/w/index.php?title=Special:Search&search=turn0image0+OR+turn0image1+OR+turn0image2+OR+turn0image3+OR+turn0image4+OR+turn0image5+OR+turn0image6+OR+turn0image7&ns0=1&fulltext=Search)
* [insource:/turn0(search|image|news|file)[0-9]+/](https://en.wikipedia.org/w/index.php?title=Special:Search&search=insource%3A%2Fturn0%28search%7Cimage%7Cnews%7Cfile%29%5B0-9%5D%2B%2F&ns0=1&fulltext=Search)

#### Gemini: [cite: 1], [span\_1][start\_span]

[Shortcut](https://en.wikipedia.org/wiki/Wikipedia%3AShortcut "Wikipedia:Shortcut")

* [WP:STARTSPAN](https://en.wikipedia.org/w/index.php?title=Wikipedia:STARTSPAN&redirect=no)[WP:STARTSPAN](https://en.wikipedia.org/wiki/Wikipedia%3ASTARTSPAN "Wikipedia:STARTSPAN")

Text copied from [Google Gemini](https://en.wikipedia.org/wiki/Google_Gemini "Google Gemini") may contain `[cite: 1]` or `[cite: 3, 12, 13]`style markers.

> Maloo founded **Kreative Machinez** in February 2010[cite: 17]. The agency provides services in search engine marketing, social media marketing, web development, and online branding[cite: 18]. The company employs more than 100 people and has worked with over 1,000 client accounts across sectors such as healthcare, real estate, and e-commerce[cite: 19, 20, 21].

— From [Parmod Maloo](https://en.wikipedia.org/wiki/Wikipedia%3ASigns_of_AI_writing/Examples/Parmod_Maloo "Wikipedia:Signs of AI writing/Examples/Parmod Maloo") in February 2026

Gemini text may also contain formatting bugs in the form of `[span_1][start_span]` and `[span_1][end_span]`.

> Riding the wave of their soundtrack success, the group released their fourth studio album, *[Fore!](https://en.wikipedia.org/wiki/Fore%21 "Fore!")[span\_2](start\_span)*, in August 1986[span\_2](end\_span). [span\_3](start\_span)The album mirrored the multi-platinum status of its predecessor and topped the *Billboard* 200 chart[span\_3](end\_span). *Fore[span\_4](start\_span)!* yielded two number-one singles on the Hot 100

— From [this July 2026 revision](https://en.wikipedia.org/w/index.php?title=&diff=1363979466&oldid=) to [Huey Lewis and the News](https://en.wikipedia.org/wiki/Huey_Lewis_and_the_News "Huey Lewis and the News")

**Links to searches**

* ["span 0 start span" OR "span 0 end span" OR "start span span 0" OR "span 1 start span" OR "span 1 end span" OR "start span span 1" OR "span 2 start span" OR "span 2 end span" OR "start span span 2"](https://en.wikipedia.org/w/index.php?search=%22span+0+start+span%22+OR+%22span+0+end+span%22+OR+%22start+span+span+0%22+OR+%22span+1+start+span%22+OR+%22span+1+end+span%22+OR+%22start+span+span+1%22+OR+%22span+2+start+span%22+OR+%22span+2+end+span%22+OR+%22start+span+span+2%22&title=Special%3ASearch&profile=advanced&fulltext=1&ns0=1&ns1=1&ns2=1&ns3=1&ns4=1&ns5=1&ns6=1&ns7=1&ns8=1&ns9=1&ns10=1&ns11=1&ns12=1&ns13=1&ns14=1&ns15=1&ns100=1&ns101=1&ns118=1&ns119=1&ns126=1&ns127=1&ns710=1&ns711=1&ns828=1&ns829=1&ns1728=1&ns1729=1)

#### Grok: grok\_card, grok\_render\_citation\_card\_json

[Shortcut](https://en.wikipedia.org/wiki/Wikipedia%3AShortcut "Wikipedia:Shortcut")

* [WP:GROKCARD](https://en.wikipedia.org/w/index.php?title=Wikipedia:GROKCARD&redirect=no)[WP:GROKCARD](https://en.wikipedia.org/wiki/Wikipedia%3AGROKCARD "Wikipedia:GROKCARD")

Text generated by Grok may occasionally include [XML](https://en.wikipedia.org/wiki/XML "XML")-styled `grok_card` tags after citations.

> Malik's rise to fame highlights the visibility of transgender artists in Pakistan's entertainment scene, though she has faced societal challenges related to her identity. [...]<grok-card data-id="e8ff4f" data-type="citation\_card">

— From [this November 2025 revision](https://en.wikipedia.org/wiki/Special%3APermanentLink/1323207968 "Special:PermanentLink/1323207968") to [Draft:Mehak Malik](https://en.wikipedia.org/wiki/Wikipedia%3ASigns_of_AI_writing/Examples/Mehak_Malik "Wikipedia:Signs of AI writing/Examples/Mehak Malik")

Grok may also include `grok_render_citation_card_json` in place of links to reference in the output text.

> Gölge was publicly revealed through trademark and patent applications filed with the Turkish Patent and Trademark Office in April 2026. The platform was showcased at the SAHA Expo 2026 in Istanbul alongside the jet-powered kamikaze UAV AYAZ. [](grok\_render\_citation\_card\_json={"cardIds":["3bb883"]})

— From revision [1352634865](https://en.wikipedia.org/wiki/Special%3APermanentLink/1352634865 "Special:PermanentLink/1352634865") of [Draft:TUSAŞ Gölge tactical UAV](https://en.wikipedia.org/wiki/Wikipedia%3ASigns_of_AI_writing/Examples/TUSA%C5%9E_G%C3%B6lge_tactical_UAV "Wikipedia:Signs of AI writing/Examples/TUSAŞ Gölge tactical UAV") in May 2026

> Gölge is a \*\*piston-engine\*\* tactical UAV optimized for long-endurance missions. The name "Gölge" (Shadow) and associated branding suggest a focus on \*\*low-observability\*\* (low radar cross-section) features. It is designed as a flexible, multi-role platform, primarily for intelligence, surveillance, and reconnaissance (ISR) roles. [](grok\_render\_citation\_card\_json={"cardIds":["993eac"]})

— From revision [1352634865](https://en.wikipedia.org/wiki/Special%3APermanentLink/1352634865 "Special:PermanentLink/1352634865") of [Draft:TUSAŞ Gölge tactical UAV](https://en.wikipedia.org/wiki/Wikipedia%3ASigns_of_AI_writing/Examples/TUSA%C5%9E_G%C3%B6lge_tactical_UAV "Wikipedia:Signs of AI writing/Examples/TUSAŞ Gölge tactical UAV") in May 2026

**Links to searches**

* [grok-card data-id](https://en.wikipedia.org/w/index.php?search=%22grok-card+data-id%22&title=Special%3ASearch&profile=advanced&fulltext=1&ns0=1&ns1=1&ns2=1&ns3=1&ns4=1&ns5=1&ns6=1&ns7=1&ns8=1&ns9=1&ns10=1&ns11=1&ns12=1&ns13=1&ns14=1&ns15=1&ns100=1&ns101=1&ns118=1&ns119=1&ns126=1&ns127=1&ns710=1&ns711=1&ns828=1&ns829=1&ns1728=1&ns1729=1)

#### DeepSeek: lenticular brackets, dagger symbols

As of June 2025, markup with [lenticular brackets](https://en.wikipedia.org/wiki/Lenticular_brackets "Lenticular brackets") and [dagger symbols](https://en.wikipedia.org/wiki/Dagger_symbol "Dagger symbol"), like `【85†L261-269】`, has also been seen. This format appears to be specific to [DeepSeek](https://en.wikipedia.org/wiki/DeepSeek "DeepSeek") and its derivatives.[[29]](https://en.wikipedia.org/wiki/Wikipedia%3ASigns_of_AI_writing#cite_note-38)

| From [this June 2025 revision](https://en.wikipedia.org/wiki/Special%3APermanentLink/1295285879 "Special:PermanentLink/1295285879") to [Draft:Gillingham High Street](https://en.wikipedia.org/wiki/Wikipedia%3ASigns_of_AI_writing/Examples/Gillingham_High_Street "Wikipedia:Signs of AI writing/Examples/Gillingham High Street") |
| --- |
| Recent initiatives aim to reverse decline. Medway Council’s Gillingham Town Centre Planning Framework (2007) and later Gillingham Business Plan identified preservation of historic shopfronts and pedestrian enhancements as prioritiesmedway.gov.ukmedway.gov.uk. In 2024 MP Naushabah Khan launched the “Love Gillingham” campaign and a high-street taskforce to improve cleanliness, safety and commerce【85†L261-269】. A community panel is drafting a Gillingham Action Plan, and events like the September 2024 “Big Day Out” carnival (2,500+ attendees) help draw people in【85†L269-274】. As of 2025 vacancy rates on the High Street were reported at about 6.2% (well below the 16% UK average)【85†L261-269】, suggesting a modest stability even as big chains have disappeared.}} |

| From [this August 2025 revision](https://en.wikipedia.org/wiki/Special%3APermanentLink/1304282215 "Special:PermanentLink/1304282215") to [Draft:Paytra](https://en.wikipedia.org/wiki/Wikipedia%3ASigns_of_AI_writing/Examples/Paytra "Wikipedia:Signs of AI writing/Examples/Paytra") |
| --- |
| Paytra Gessler, known professionally as Paytra, is an American singer‑songwriter whose music combines pop and hip‑hop with R&B, funk and soul influences. She gained attention in the early 2020s with her genre‑bending singles and her feminist message. Paytra’s releases include the EP Momma Taught Me How to Fight and the album Tiny But Mighty (both 2023)【854140639155648†L119-L123】, as well as the singles “Villain Era” (2023), “Bright Red Flags” (2023)【331835262276082†L127-L149】, “Good Girls Don’t Make History” (2024)【610406519434033†L284-L290】, “All Kinda Bitches” (2024)【695032903925577†L42-L52】 and “World’s About to Get Crazy” (2024)【466616601965079†L42-L60】.}} |

| From [Draft:JAF-GT300](https://en.wikipedia.org/wiki/Wikipedia%3ASigns_of_AI_writing/Examples/JAF-GT300 "Wikipedia:Signs of AI writing/Examples/JAF-GT300") in March 2026 |
| --- |
| ``` JAF-GT300 cars are generally Japanese makes or specially constructed “silhouette” vehicles, distinct from the FIA [[Group GT3]] cars, also eligible in GT300【29†L582-L589】. The Japan Automobile Federation (JAF) is the national motorsport authority in Japan and co-sponsors Super GT, setting technical rules for JAF-GT cars【32†L142-L149】. In practice, a GT300 field includes three types of cars: (1) **JAF-GT** cars (JAF-regulation, often modified Japanese road cars or special designs), (2) **FIA GT3** cars (homologated under FIA GT3 rules), and (3) **Mother Chassis** (MC) cars (built on a standard tubular chassis by Dome)【29†L598-L606】. ``` |

**Links to searches**

* [insource:/【[0-9]+†/](https://en.wikipedia.org/w/index.php?search=insource%3A%2F%E3%80%90%5B0-9%5D%2B%E2%80%A0%2F&title=Special%3ASearch&profile=advanced&fulltext=1&ns118=1) (in drafts only)

#### Perplexity: attached\_file, ppl-ai-file-upload

As of fall 2025, tags like `[attached_file:1]` and `[web:1]` have been seen at the end of sentences. This may be [Perplexity](https://en.wikipedia.org/wiki/Perplexity_AI "Perplexity AI")-specific.[[30]](https://en.wikipedia.org/wiki/Wikipedia%3ASigns_of_AI_writing#cite_note-wildperplexityappeared-39)

> During his time as CEO, Philip Morris’s reputation management and media relations brought together business and news interests in ways that later became controversial, with effects still debated in contemporary regulatory and legal discussions.[attached\_file:1]

— From [this October 2025 revision](https://en.wikipedia.org/w/index.php?title=&diff=1316436509&oldid=) to [Hamish Maxwell](https://en.wikipedia.org/wiki/Hamish_Maxwell "Hamish Maxwell")

Perplexity may also cite text to an [Amazon S3](https://en.wikipedia.org/wiki/Amazon_S3 "Amazon S3") bucket, with `ppl-ai-file-upload` in the URL.

#### Unclassified: :::writing

As of June 1, 2026, markup in the format `:::writing{variant="document" id="[NUMBER]"}`, where [NUMBER] is a random 5-digit number, has been spotted; the triple colons at the beginning may or may not be interpreted as an indent. Triple colons at the end of the "document" are often paired with this. The markup may or may not be in other languages.

**Examples**

> I can help draft a Wikipedia-style biography, but I should be clear: a page written this way is not automatically suitable for Wikipedia. Wikipedia requires facts to be supported by independent, reliable sources, and promotional or unsourced claims may be removed.
>
> Based only on the information you've shared with me, here's a professional encyclopedia-style draft:
>
> :   :   :   writing{variant="document" id="68427"}

— From [this revision](https://en.wikipedia.org/wiki/Special%3APermanentLink/1358854076 "Special:PermanentLink/1358854076") to [User:Drrbharanidharan](https://en.wikipedia.org/wiki/User%3ADrrbharanidharan "User:Drrbharanidharan"); note the indent.

> ```
> :::écriture{variante="document" id="28471"} == AK7== '''AK7''', aussi connu sous le nom de '''Yanixak7''', [...] == Discographie == === Célibataires ===	 •	 « Digba Kistha » (2022)	 •	 ''Tals'' (2025) == Privilèges externes ==
> pédia :
>
> :::writing{variant=“document” id=“51724”}
> == Liens externes ==
> 	•	[https://redacted-link.invalid Spotify officiel]
> 	•	[https://redacted-link.invalid Apple Music officiel]
> 	•	[https://redacted-link.invalid YouTube officiel]
> 	•	[https://redacted-link.invalid Instagram officiel]
> :::
>
> Et petite corr :::
> ```

— From [this revision](https://en.wikipedia.org/wiki/Special%3APermanentLink/1357217465 "Special:PermanentLink/1357217465") to [Draft:Ak7](https://en.wikipedia.org/wiki/Draft%3AAk7 "Draft:Ak7"); links have been redacted.

### Non-existent or out-of-place categories

[Shortcut](https://en.wikipedia.org/wiki/Wikipedia%3AShortcut "Wikipedia:Shortcut")

* [WP:AIREDCAT](https://en.wikipedia.org/w/index.php?title=Wikipedia:AIREDCAT&redirect=no)[WP:AIREDCAT](https://en.wikipedia.org/wiki/Wikipedia%3AAIREDCAT "Wikipedia:AIREDCAT")

LLMs may hallucinate non-existent categories, sometimes for generic concepts that *seem like* plausible category titles (or [SEO](https://en.wikipedia.org/wiki/Search_engine_optimization "Search engine optimization") keywords), and sometimes because their training set includes obsolete and renamed categories. These will appear as [red links](https://en.wikipedia.org/wiki/Wikipedia%3AREDNOT "Wikipedia:REDNOT"). You may also find category redirects, such as the longtime spammer favorite [Category:Entrepreneurs](https://en.wikipedia.org/wiki/Category%3AEntrepreneurs "Category:Entrepreneurs"). Sometimes, broken categories may be deleted by reviewers, so if you suspect a page may be LLM-generated, it may be worth checking earlier revisions.

Of course, none of this section should be treated as a hard-and-fast rule. New users are unlikely to know about Wikipedia's style guidelines for these sections, and returning editors may be used to old categories that have since been deleted.

**Examples**

> ```
> [[Category:American hip hop musicians]]
> ```

— From [this August 2025 revision](https://en.wikipedia.org/wiki/Special%3APermanentLink/1304282215 "Special:PermanentLink/1304282215") to [Draft:Paytra](https://en.wikipedia.org/wiki/Wikipedia%3ASigns_of_AI_writing/Examples/Paytra "Wikipedia:Signs of AI writing/Examples/Paytra")

rather than

> ```
> [[Category:American hip-hop musicians]]
> ```

### Non-existent templates

LLMs often hallucinate non-existent templates (especially plausible-sounding types of [infoboxes](https://en.wikipedia.org/wiki/Wikipedia%3AInfoboxes "Wikipedia:Infoboxes")) and template parameters. These will also appear as red links, and non-existent template parameters in existing templates have no effect. LLMs may also use templates that were deleted after their knowledge cutoff date (such as the [lang-?? series](https://en.wikipedia.org/wiki/Wikipedia%3ATemplates_for_discussion/Log/2024_September_27/lang-%3F%3F_templates "Wikipedia:Templates for discussion/Log/2024 September 27/lang-?? templates")).

**Examples**

> ```
> {{Infobox ancient population
> | name = Gangetic Hunter-Gatherer (GHG)
> | image = [[File:GHG_reconstruction.png|250px]]
> | caption = Artistic reconstruction of a Gangetic Hunter-Gatherer male, based on Mesolithic skeletal data from the Ganga Valley
> | regions = Ganga Valley (from Haryana to Bengal, between the Vindhyas and Himalayas)
> | period = Mesolithic–Early Neolithic (10,000–5,000 BCE)
> | descendants = Gangetic peoples, Indus Valley Civilisation, South Indian populations
> | archaeological_sites = Bhimbetka, Sarai Nahar Rai, Mahadaha, Jhusi, Chirand
> }}
> ```

— From [this revision](https://en.wikipedia.org/wiki/Special%3APermanentLink/1326132735 "Special:PermanentLink/1326132735") to [Draft:Gangetic hunter-gatherers](https://en.wikipedia.org/wiki/Wikipedia%3ASigns_of_AI_writing/Examples/Gangetic_hunter-gatherers "Wikipedia:Signs of AI writing/Examples/Gangetic hunter-gatherers")

rather than

> ```
> {{Infobox archaeological culture
> | name = Gangetic Hunter-Gatherer (GHG)
> | map = [[File:GHG_reconstruction.png|250px]]
> | mapcaption = Artistic reconstruction of a Gangetic Hunter-Gatherer male, based on Mesolithic skeletal data from the Ganga Valley
> | region = Ganga Valley (from Haryana to Bengal, between the Vindhyas and Himalayas)
> | period = Mesolithic–Early Neolithic (10,000–5,000 BCE)
> | followedby = Gangetic peoples, Indus Valley Civilisation, South Indian populations
> | majorsites = Bhimbetka, Sarai Nahar Rai, Mahadaha, Jhusi, Chirand
> }}
> ```

**Non-infobox examples**

> ```
> == <!-- EDIT BELOW THIS LINE --> == markup
> {{Update submission |reasons=Complete biographical rewrite executed to strip out promotional prose. Incorporated independent third-party literary journal analysis from Ashvamegh Journal to satisfy WP:NBIOGRAPHY. |ts=2026-06-08T12:19:00Z}}
> ```

— From [this revision](https://en.wikipedia.org/wiki/Special%3APermanentLink/1358339625 "Special:PermanentLink/1358339625") to [User:Blueskyreader/sandbox](https://en.wikipedia.org/wiki/User%3ABlueskyreader/sandbox "User:Blueskyreader/sandbox")

#### Links to searches

* [Wikipedia:Database reports/Transclusions of non-existent templates](https://en.wikipedia.org/wiki/Wikipedia%3ADatabase_reports/Transclusions_of_non-existent_templates "Wikipedia:Database reports/Transclusions of non-existent templates") – many of these broken templates are legitimate mistakes, but the "infobox" and "lang" sections are likely to contain LLM hallucinations

## Citations

For non-AI-specific guidance about this, see [Wikipedia:Fictitious references](https://en.wikipedia.org/wiki/Wikipedia%3AFictitious_references "Wikipedia:Fictitious references").

[Shortcut](https://en.wikipedia.org/wiki/Wikipedia%3AShortcut "Wikipedia:Shortcut")

* [WP:AIFICTREF](https://en.wikipedia.org/w/index.php?title=Wikipedia:AIFICTREF&redirect=no)[WP:AIFICTREF](https://en.wikipedia.org/wiki/Wikipedia%3AAIFICTREF "Wikipedia:AIFICTREF")

See also: [Template:Failed verification](https://en.wikipedia.org/wiki/Template%3AFailed_verification "Template:Failed verification")

### Broken external links

If a new article or draft has multiple citations with external links, and **several** of them are broken (e.g., non-existent websites or [404 errors](https://en.wikipedia.org/wiki/404_error "404 error")), this is a strong sign of an AI-generated page, particularly if the dead links are not found in website archiving sites like the [Internet Archive](https://en.wikipedia.org/wiki/Internet_Archive "Internet Archive"). Most links [become broken over time](https://en.wikipedia.org/wiki/Link_rot "Link rot"), but these factors make it unlikely that the link was ever real.

Watch out for: Links that don't work for you, but do work for other people (e.g., journal articles accessed through a university library); links that were mangled by bots and scripts (e.g., to add incorrect identifiers or to remove seemingly unnecessary parts of the URL); links that are missing the start or end (a sign of a human copy/pasting the URL).

### Invalid DOI and ISBNs

For non-AI-specific guidance about DOI and ISBNs, see [Wikipedia:DOI](https://en.wikipedia.org/wiki/Wikipedia%3ADOI "Wikipedia:DOI") and [Wikipedia:ISBN](https://en.wikipedia.org/wiki/Wikipedia%3AISBN "Wikipedia:ISBN").

A [checksum](https://en.wikipedia.org/wiki/Checksum "Checksum") can be used to verify [ISBNs](https://en.wikipedia.org/wiki/ISBN "ISBN"). An invalid checksum is a very likely sign that an ISBN is incorrect, and citation templates display [a warning](https://en.wikipedia.org/wiki/Help%3ACS1_errors#bad_isbn "Help:CS1 errors") if so. Similarly, [DOIs](https://en.wikipedia.org/wiki/Digital_object_identifier "Digital object identifier") are more resistant to link rot than regular hyperlinks. Unresolvable DOIs and invalid ISBNs can be indicators of [hallucinated](https://en.wikipedia.org/wiki/Hallucination_%28AI%29 "Hallucination (AI)") references.

### DOIs that lead to unrelated articles

A LLM may generate references to non-existent scholarly articles with DOIs that appear valid but are, in reality, assigned to unrelated articles. Example passage generated by ChatGPT:

> Ohm’s Law applies to many materials and components that are "ohmic," meaning their resistance remains constant regardless of the applied voltage or current. However, it does not hold for non-linear devices like diodes or transistors [1][2].
>
> 1. M. E. Van Valkenburg, “The validity and limitations of Ohm’s law in non-linear circuits,” Proceedings of the IEEE, vol. 62, no. 6, pp. 769–770, Jun. 1974. [doi](https://en.wikipedia.org/wiki/Doi_%28identifier%29 "Doi (identifier)"):[10.1109/PROC.1974.9547](https://doi.org/10.1109/PROC.1974.9547)
>
> 2. C. L. Fortescue, “Ohm’s Law in alternating current circuits,” Proceedings of the IEEE, vol. 55, no. 11, pp. 1934–1936, Nov. 1967. [doi](https://en.wikipedia.org/wiki/Doi_%28identifier%29 "Doi (identifier)"):[10.1109/PROC.1967.6033](https://doi.org/10.1109/PROC.1967.6033)

Both *Proceedings of the IEEE* citations are completely made up. The DOIs lead to different citations and have other problems as well. For instance, [C. L. Fortescue](https://en.wikipedia.org/wiki/Charles_LeGeyt_Fortescue "Charles LeGeyt Fortescue") was dead for 30+ years at the purported time of writing, and [Vol 55, Issue 11](https://ieeexplore.ieee.org/xpl/tocresult.jsp?isnumber=31102&punumber=5) does not list any articles that match anything remotely close to the information given in reference 2.

Note: From 2018 to 2023, [a UX issue in VisualEditor](https://phabricator.wikimedia.org/T198456) led many editors to accidentally insert references to [PubMed](https://en.wikipedia.org/wiki/PubMed "PubMed") articles with low ID numbers (PMIDs), resulting in obviously irrelevant citations like an article about rat livers (PMID 9) being cited in [List of Disney television films](https://en.wikipedia.org/wiki/Special%3ADiff/972043377 "Special:Diff/972043377") in 2020. These may resemble AI hallucinations (and should be fixed regardless), but they generally are not.

### Book citations without page numbers or URLs

LLMs often generate book citations that do not include page numbers. This passage, for example, was generated by ChatGPT:

> Ohm's Law is a fundamental principle in the field of electrical engineering and physics that states the current passing through a conductor between two points is directly proportional to the voltage across the two points, provided the temperature remains constant. Mathematically, it is expressed as V=IR, where V is the voltage, I is the current, and R is the resistance. The law was formulated by German physicist Georg Simon Ohm in 1827, and it serves as a cornerstone in the analysis and design of electrical circuits [1].
>
> 1. Dorf, R. C., & Svoboda, J. A. (2010). Introduction to Electric Circuits (8th ed.). Hoboken, NJ: John Wiley & Sons. [ISBN](https://en.wikipedia.org/wiki/ISBN_%28identifier%29 "ISBN (identifier)") [9780470521571](https://en.wikipedia.org/wiki/Special%3ABookSources/9780470521571 "Special:BookSources/9780470521571").

The book reference appears valid – a book on electric circuits would likely have information about Ohm's law – but without the page number, that citation is not useful for verifying the claims in the prose.

Some LLM-generated book citations include page numbers, and the book exists, but the cited pages do not verify the text. Signs to look out for: the book is on a somewhat general topic or frequently referenced in its field, and the citation does not include a URL (not mandatory for book citations, but editors creating legitimate book citations often include a link to [an online version of the text](https://en.wikipedia.org/wiki/Wikipedia%3ABook_sources#Online_text "Wikipedia:Book sources")). Example:

> Analysts note that traditionalists often appeal to prudence, stability, and Edmund Burke’s notion of “prescription,” while reactionaries invoke moral urgency and cultural emergency, framing the present as a deviation from an idealized past. [1]
>
> 1. Goldwater, Barry (1960). The Conscience of a Conservative. Victor Publishing. p. 12.

This may look like a reasonable citation, but searching an [online version of the book for "Burke" produces no results](https://www.google.com/books/edition/The_Conscience_of_a_Conservative/PKd_EQAAQBAJ?hl=en&gbpv=1&bsq=burke).

### Incorrect or unconventional use of references

[Shortcut](https://en.wikipedia.org/wiki/Wikipedia%3AShortcut "Wikipedia:Shortcut")

* [WP:AICITESTYLE](https://en.wikipedia.org/w/index.php?title=Wikipedia:AICITESTYLE&redirect=no)[WP:AICITESTYLE](https://en.wikipedia.org/wiki/Wikipedia%3AAICITESTYLE "Wikipedia:AICITESTYLE")

AI tools may have been prompted to include references, and make an attempt to do so as Wikipedia expects, but fail with some key implementation details or stand out when compared with conventions.

**Examples**

In the first example, note the incorrect attempt at re-using references. The tool used there was not capable of searching for non-confabulated sources (as it was done the day before [Bing](https://en.wikipedia.org/wiki/Microsoft_Bing "Microsoft Bing") Deep Search launched) but nonetheless found one real reference. The syntax for re-using the references was incorrect.

In that case, the *Smith, R. J.* source – being the "third source" the tool presumably generated the link '[https://pubmed.ncbi.nlm.nih.gov/3'](https://pubmed.ncbi.nlm.nih.gov/3%27) (which has a PMID reference of 3) – is also completely irrelevant to the body of the article. The user did not check the reference before they converted it to a {{[cite journal](https://en.wikipedia.org/wiki/Template%3ACite_journal "Template:Cite journal")}} reference, even though the links resolve.

The LLM in that case has diligently included the incorrect re-use syntax after every single full stop.

| From [this December 2023 revision](https://en.wikipedia.org/wiki/Special%3APermanentLink/1188218670 "Special:PermanentLink/1188218670") to [Cognitive orthotics](https://en.wikipedia.org/wiki/Cognitive_orthotics "Cognitive orthotics") |
| --- |
| ``` For over thirty years, computers have been utilized in the rehabilitation of individuals with brain injuries. Initially, researchers delved into the potential of developing a "prosthetic memory."<ref>Fowler R, Hart J, Sheehan M. A prosthetic memory: an application of the prosthetic environment concept. ''Rehabil Counseling Bull''. 1972;15:80–85.</ref> However, by the early 1980s, the focus shifted towards addressing brain dysfunction through repetitive practice.<ref>{{Cite journal |last=Smith |first=R. J. |last2=Bryant |first2=R. G. |date=1975-10-27 |title=Metal substitutions incarbonic anhydrase: a halide ion probe study |url=https://pubmed.ncbi.nlm.nih.gov/3 |journal=Biochemical and Biophysical Research Communications |volume=66 |issue=4 |pages=1281–1286 |doi=10.1016/0006-291x(75)90498-2 |issn=0006-291X |pmid=3}}</ref> Only a few psychologists were developing rehabilitation software for individuals with Traumatic Brain Injury (TBI), resulting in a scarcity of available programs.<sup>[3]</sup> Cognitive rehabilitation specialists opted for commercially available computer games that were visually appealing, engaging, repetitive, and entertaining, theorizing their potential remedial effects on neuropsychological dysfunction.<sup>[3]</sup> ``` |

Some LLMs or chatbot interfaces use the character `↩` around footnotes. The character is often used on other websites to provide a link for the user to jump back to the article after reading the footnote.

| From [this August 2025 revision](https://en.wikipedia.org/wiki/Special%3APermanentLink/1304723248 "Special:PermanentLink/1304723248") to [Draft:CureMD](https://en.wikipedia.org/wiki/Wikipedia%3ASigns_of_AI_writing/Examples/CureMD "Wikipedia:Signs of AI writing/Examples/CureMD") |
| --- |
| References  Would you like help formatting and submitting this to Wikipedia, or do you plan to post it yourself? I can guide you step-by-step through that too.  **Footnotes**   1. KLAS Research. (2024). *Top Performing RCM Vendors 2024*. https://klasresearch.com ↩ ↩2 2. PR Newswire. (2025, February 18). *CureMD AI Scribe Launch Announcement*. https://www.prnewswire.com/news-releases/curemd-ai-scribe ↩ |

### utm\_source=

ChatGPT may add the [UTM parameters](https://en.wikipedia.org/wiki/UTM_parameter "UTM parameter") `utm_source=openai` or `utm_source=chatgpt.com` to URLs that it is using as sources. Microsoft Copilot may add `utm_source=copilot.com` to URLs. Grok uses `referrer=grok.com`. Other LLMs, such as Gemini or Claude, use UTM parameters less often.[[g]](https://en.wikipedia.org/wiki/Wikipedia%3ASigns_of_AI_writing#cite_note-40)

Note: While this near-definitively proves ChatGPT's involvement,[[h]](https://en.wikipedia.org/wiki/Wikipedia%3ASigns_of_AI_writing#cite_note-41) it doesn't prove, on its own, that ChatGPT also generated the writing. Some editors use AI tools to find citations for existing text; this will be apparent in the edit history.

**Examples**

> Following their marriage, Burgess and Graham settled in Cheshire, England, where Burgess serves as the head coach for the Warrington Wolves rugby league team. [https://www.theguardian.com/sport/2025/feb/11/sam-burgess-interview-warrington-rugby-league-luke-littler?utm\_source=chatgpt.com]

— From [this revision](https://en.wikipedia.org/w/index.php?title=&diff=1277944793&oldid=) to [Sam Burgess](https://en.wikipedia.org/wiki/Sam_Burgess "Sam Burgess")

#### Links to searches

* [utm\_source=chatgpt.com](https://en.wikipedia.org/w/index.php?search=%utm_source=chatgpt.com%22&title=Special:Search&profile=advanced&fulltext=1&ns0=1)
* [insource:"utm\_source=chatgpt.com"](https://en.wikipedia.org/w/index.php?search=insource%3A%22utm_source%3Dchatgpt.com%22&title=Special%3ASearch&profile=advanced&fulltext=1&ns0=1)
* [insource:"utm\_source=openai"](https://en.wikipedia.org/w/index.php?search=insource%3A%22utm_source%3Dopenai%22&title=Special%3ASearch&profile=advanced&fulltext=1&ns0=1)
* [insource:"utm\_source=copilot.com"](https://en.wikipedia.org/w/index.php?search=insource%3A%22utm_source%3Dcopilot.com%22&title=Special%3ASearch&profile=advanced&fulltext=1&ns0=1)
* [insource:"referrer=grok.com"](https://en.wikipedia.org/w/index.php?search=insource%3A%22referrer%3Dgrok.com%22&title=Special%3ASearch&profile=advanced&fulltext=1&ns0=1)

### Named references declared in references section but unused in article body

A common referencing error produced by LLMs involves sources in a `<references>` tag which are not used inline. LLMs can also produce [named references](https://en.wikipedia.org/wiki/Wikipedia%3ANAMEDREF "Wikipedia:NAMEDREF") which are not defined, although this can also be the result of a copy-paste from a different article.
**Examples**

| From [this May 2025 revision](https://en.wikipedia.org/wiki/Special%3ADiff/1291491974#References "Special:Diff/1291491974") to [Draft:Josef von Rickenbach](https://en.wikipedia.org/wiki/Wikipedia%3ASigns_of_AI_writing/Examples/Josef_von_Rickenbach "Wikipedia:Signs of AI writing/Examples/Josef von Rickenbach") |
| --- |
| ``` <references> <ref name=\"fiercebiotech\">https://www.fiercebiotech.com/cro/parexel-co-founder-josef-von-rickenbach-to-end-35-year-run-as-ceo</ref> <ref name=\"statnews\">https://www.statnews.com/2018/03/16/parexel-josef-von-rickenbach-cro/</ref> <ref name=\"mclean\">https://www.mcleanhospital.org/news/three-prominent-community-members-join-mcleans-board</ref> <ref name=\"twst\">https://www.twst.com/bio/josef-h-von-rickenbach/</ref> </references> ```  Result  **Cite error: A [list-defined reference](https://en.wikipedia.org/wiki/Help%3AFootnotes#WP:LDR "Help:Footnotes") named "\"fiercebiotech\"" is not used in the content (see the [help page](https://en.wikipedia.org/wiki/Help%3ACite_errors/Cite_error_references_missing_key "Help:Cite errors/Cite error references missing key")).**  **Cite error: A [list-defined reference](https://en.wikipedia.org/wiki/Help%3AFootnotes#WP:LDR "Help:Footnotes") named "\"statnews\"" is not used in the content (see the [help page](https://en.wikipedia.org/wiki/Help%3ACite_errors/Cite_error_references_missing_key "Help:Cite errors/Cite error references missing key")).**  **Cite error: A [list-defined reference](https://en.wikipedia.org/wiki/Help%3AFootnotes#WP:LDR "Help:Footnotes") named "\"mclean\"" is not used in the content (see the [help page](https://en.wikipedia.org/wiki/Help%3ACite_errors/Cite_error_references_missing_key "Help:Cite errors/Cite error references missing key")).**  **Cite error: A [list-defined reference](https://en.wikipedia.org/wiki/Help%3AFootnotes#WP:LDR "Help:Footnotes") named "\"twst\"" is not used in the content (see the [help page](https://en.wikipedia.org/wiki/Help%3ACite_errors/Cite_error_references_missing_key "Help:Cite errors/Cite error references missing key")).** |

| From [this May 2025 revision](https://en.wikipedia.org/wiki/Special%3ADiff/1291558682#References "Special:Diff/1291558682") to [Draft:Caligomos Art](https://en.wikipedia.org/wiki/Wikipedia%3ASigns_of_AI_writing/Examples/Caligomos_Art "Wikipedia:Signs of AI writing/Examples/Caligomos Art") |
| --- |
| ``` <references><ref name="wooart-about">[https://wooart.ca/about-caligomos-art About Caligomos Art – WOO ART]</ref> <ref name="wooart-home">[https://wooart.ca/ Home – WOO ART]</ref> <ref name="discover-leeds">[https://discoverdirectory.leedsgrenville.com/Home/View/woo-art-gallery Woo Art Gallery – Discover Leeds Grenville]</ref> <ref name="book-amazon">Woo, John HR. ''The Book of Caligomos Art''. Amazon KDP, 2025. ISBN 979-8-987654321-0.</ref></references> ```  Result  **Cite error: A [list-defined reference](https://en.wikipedia.org/wiki/Help%3AFootnotes#WP:LDR "Help:Footnotes") named "wooart-about" is not used in the content (see the [help page](https://en.wikipedia.org/wiki/Help%3ACite_errors/Cite_error_references_missing_key "Help:Cite errors/Cite error references missing key")).**  **Cite error: A [list-defined reference](https://en.wikipedia.org/wiki/Help%3AFootnotes#WP:LDR "Help:Footnotes") named "wooart-home" is not used in the content (see the [help page](https://en.wikipedia.org/wiki/Help%3ACite_errors/Cite_error_references_missing_key "Help:Cite errors/Cite error references missing key")).**  **Cite error: A [list-defined reference](https://en.wikipedia.org/wiki/Help%3AFootnotes#WP:LDR "Help:Footnotes") named "discover-leeds" is not used in the content (see the [help page](https://en.wikipedia.org/wiki/Help%3ACite_errors/Cite_error_references_missing_key "Help:Cite errors/Cite error references missing key")).**  **Cite error: A [list-defined reference](https://en.wikipedia.org/wiki/Help%3AFootnotes#WP:LDR "Help:Footnotes") named "book-amazon" is not used in the content (see the [help page](https://en.wikipedia.org/wiki/Help%3ACite_errors/Cite_error_references_missing_key "Help:Cite errors/Cite error references missing key")).** |

**Links to searches**

* [Category:Pages with incorrect ref formatting](https://en.wikipedia.org/wiki/Category%3APages_with_incorrect_ref_formatting "Category:Pages with incorrect ref formatting")
* [Pages without inline citations](https://en.wikipedia.org/w/index.php?title=Special:WhatLinksHere/Template:No_footnotes&hidelinks=1&hidetrans=1)
* ["Cite error: A list-defined reference named" + "is not used in the content (see the help page)."](https://en.wikipedia.org/w/index.php?search=%22Cite+error%3A+A+list-defined+reference+named%22+%22is+not+used+in+the+content+%28see+the+help+page%29.%22&title=Special%3ASearch&profile=advanced&fulltext=1&ns0=1&ns2=1&ns118=1)

## Comment-specific indicators

[Shortcuts](https://en.wikipedia.org/wiki/Wikipedia%3AShortcut "Wikipedia:Shortcut")

* [WP:AICOMMENT](https://en.wikipedia.org/w/index.php?title=Wikipedia:AICOMMENT&redirect=no)[WP:AICOMMENT](https://en.wikipedia.org/wiki/Wikipedia%3AAICOMMENT "Wikipedia:AICOMMENT")
* [WP:AICOMMENTS](https://en.wikipedia.org/w/index.php?title=Wikipedia:AICOMMENTS&redirect=no)[WP:AICOMMENTS](https://en.wikipedia.org/wiki/Wikipedia%3AAICOMMENTS "Wikipedia:AICOMMENTS")

Further information: [Wikipedia:Signs of AI-generated comments](https://en.wikipedia.org/wiki/Wikipedia%3ASigns_of_AI-generated_comments "Wikipedia:Signs of AI-generated comments")

See also: [Wikipedia:Identifying LLM unblock requests](https://en.wikipedia.org/wiki/Wikipedia%3AIdentifying_LLM_unblock_requests "Wikipedia:Identifying LLM unblock requests") and [Wikipedia:The LLM-written ANI report](https://en.wikipedia.org/wiki/Wikipedia%3AThe_LLM-written_ANI_report "Wikipedia:The LLM-written ANI report")

In many cases, some users have copy-pasted text from AI chatbots into their comments. Comments suspected of having been pasted from an LLM may be collapsed via {{[collapse AI](https://en.wikipedia.org/wiki/Template%3ACollapse_AI "Template:Collapse AI")}} per [WP:AITALK](https://en.wikipedia.org/wiki/Wikipedia%3AAITALK "Wikipedia:AITALK"). Asides from making any of the mistakes listed on this page, editors who use large language models or similar technology to write their comments are also likely to:

* [Misquote policies and guidelines](https://en.wikipedia.org/wiki/Wikipedia%3AAIFICTPOLICY "Wikipedia:AIFICTPOLICY") and [cite made-up shortcuts](https://en.wikipedia.org/wiki/Wikipedia%3AAISHORTCUT "Wikipedia:AISHORTCUT") that don't lead to any existing project page.
* [Transclude maintenance banners](https://en.wikipedia.org/wiki/Wikipedia%3AAITRANSCLUSION "Wikipedia:AITRANSCLUSION") whenever they mention them.
* Post lengthy comments [divided into sections with titles](https://en.wikipedia.org/wiki/Wikipedia%3AAISECTION "Wikipedia:AISECTION"), either written in [Markdown](https://en.wikipedia.org/wiki/Wikipedia%3AMARKDOWN "Wikipedia:MARKDOWN"), plain text, or as [level-2 or level-3 subheadings](https://en.wikipedia.org/wiki/Wikipedia%3AAISUBHEADING "Wikipedia:AISUBHEADING").
* [Assure](https://en.wikipedia.org/wiki/Wikipedia%3AAIASSURANCE "Wikipedia:AIASSURANCE") other editors that the content they have produced adheres to Wikipedia's policies and guidelines, or that they are trying to make sure of that.
* [Request input from other editors](https://en.wikipedia.org/wiki/Wikipedia%3AAIWANTFEEDBACK "Wikipedia:AIWANTFEEDBACK") to help them determine [exactly what they need to improve](https://en.wikipedia.org/wiki/Wikipedia%3AWHERESTHEAI "Wikipedia:WHERESTHEAI").
* Accuse those who call them out for AI use of [acting on speculation](https://en.wikipedia.org/wiki/Wikipedia%3ACAAAOS "Wikipedia:CAAAOS") based on their [writing style](https://en.wikipedia.org/wiki/Wikipedia%3ASTYLISTIC "Wikipedia:STYLISTIC") and [failing to present stronger evidence](https://en.wikipedia.org/wiki/Wikipedia%3ANOPROOFOFAI "Wikipedia:NOPROOFOFAI") that they used AI.

**Links to searches**

|  |  |
| --- | --- |
| * to ensure the article/content/draft/page...   + [adheres to Wikipedia's ...](https://en.wikipedia.org/w/index.php?search=%22to+ensure+the+article+adheres+to+Wikipedia%27s%22+OR+%22to+ensure+the+content+adheres+to+Wikipedia%27s%22+OR+%22to+ensure+the+draft+adheres+to+Wikipedia%27s%22+OR+%22to+ensure+the+page+adheres+to+Wikipedia%27s%22+OR+%22to+ensure+it+adheres+to+Wikipedia%27s%22&title=Special%3ASearch&profile=advanced&fulltext=1&ns1=1&ns3=1&ns4=1&ns5=1&ns119=1)   + [aligns with Wikipedia's ...](https://en.wikipedia.org/w/index.php?search=%22to+ensure+the+article+aligns+with+Wikipedia%27s%22+OR+%22to+ensure+the+content+aligns+with+Wikipedia%27s%22+OR+%22to+ensure+the+draft+aligns+with+Wikipedia%27s%22+OR+%22to+ensure+the+page+aligns+with+Wikipedia%27s%22+OR+%22to+ensure+it+aligns+with+Wikipedia%27s%22&title=Special%3ASearch&profile=advanced&fulltext=1&ns1=1&ns3=1&ns4=1&ns5=1&ns119=1)   + [complies with Wikipedia's ...](https://en.wikipedia.org/w/index.php?search=%22to+ensure+the+article+complies+with+Wikipedia%27s%22+OR+%22to+ensure+the+content+complies+with+Wikipedia%27s%22+OR+%22to+ensure+the+draft+complies+with+Wikipedia%27s%22+OR+%22to+ensure+the+page+complies+with+Wikipedia%27s%22+OR+%22to+ensure+it+complies+with+Wikipedia%27s%22&title=Special%3ASearch&profile=advanced&fulltext=1&ns1=1&ns3=1&ns4=1&ns5=1&ns119=1)   + [follows Wikipedia's ...](https://en.wikipedia.org/w/index.php?search=%22to+ensure+the+article+follows+Wikipedia%27s%22+OR+%22to+ensure+the+content+follows+Wikipedia%27s%22+OR+%22to+ensure+the+draft+follows+Wikipedia%27s%22+OR+%22to+ensure+the+page+follows+Wikipedia%27s%22+OR+%22to+ensure+it+follows+Wikipedia%27s%22&title=Special%3ASearch&profile=advanced&fulltext=1&ns1=1&ns3=1&ns4=1&ns5=1&ns119=1)   + [meets Wikipedia's ...](https://en.wikipedia.org/w/index.php?search=%22to+ensure+the+article+meets+Wikipedia%27s%22+OR+%22to+ensure+the+content+meets+Wikipedia%27s%22+OR+%22to+ensure+the+draft+meets+Wikipedia%27s%22+OR+%22to+ensure+the+page+meets+Wikipedia%27s%22+OR+%22to+ensure+it+meets+Wikipedia%27s%22&title=Special%3ASearch&profile=advanced&fulltext=1&ns1=1&ns3=1&ns4=1&ns5=1&ns119=1) | * to ensure that the article/content/draft/page...   + [adheres to Wikipedia's ...](https://en.wikipedia.org/w/index.php?search=%22to+ensure+that+the+article+adheres+to+Wikipedia%27s%22+OR+%22to+ensure+that+the+content+adheres+to+Wikipedia%27s%22+OR+%22to+ensure+that+the+draft+adheres+to+Wikipedia%27s%22+OR+%22to+ensure+that+the+page+adheres+to+Wikipedia%27s%22+OR+%22to+ensure+that+it+adheres+to+Wikipedia%27s%22&title=Special%3ASearch&profile=advanced&fulltext=1&ns1=1&ns3=1&ns4=1&ns5=1&ns119=1)   + [aligns with Wikipedia's ...](https://en.wikipedia.org/w/index.php?search=%22to+ensure+that+the+article+aligns+with+Wikipedia%27s%22+OR+%22to+ensure+that+the+content+aligns+with+Wikipedia%27s%22+OR+%22to+ensure+that+the+draft+aligns+with+Wikipedia%27s%22+OR+%22to+ensure+that+the+page+aligns+with+Wikipedia%27s%22+OR+%22to+ensure+that+it+aligns+with+Wikipedia%27s%22&title=Special%3ASearch&profile=advanced&fulltext=1&ns1=1&ns3=1&ns4=1&ns5=1&ns119=1)   + [complies with Wikipedia's ...](https://en.wikipedia.org/w/index.php?search=%22to+ensure+that+the+article+complies+with+Wikipedia%27s%22+OR+%22to+ensure+that+the+content+complies+with+Wikipedia%27s%22+OR+%22to+ensure+that+the+draft+complies+with+Wikipedia%27s%22+OR+%22to+ensure+that+the+page+complies+with+Wikipedia%27s%22+OR+%22to+ensure+that+it+complies+with+Wikipedia%27s%22&title=Special%3ASearch&profile=advanced&fulltext=1&ns1=1&ns3=1&ns4=1&ns5=1&ns119=1)   + [follows Wikipedia's ...](https://en.wikipedia.org/w/index.php?search=%22to+ensure+that+the+article+follows+Wikipedia%27s%22+OR+%22to+ensure+that+the+content+follows+Wikipedia%27s%22+OR+%22to+ensure+that+the+draft+follows+Wikipedia%27s%22+OR+%22to+ensure+that+the+page+follows+Wikipedia%27s%22+OR+%22to+ensure+that+it+follows+Wikipedia%27s%22&title=Special%3ASearch&profile=advanced&fulltext=1&ns1=1&ns3=1&ns4=1&ns5=1&ns119=1)   + [meets Wikipedia's ...](https://en.wikipedia.org/w/index.php?search=%22to+ensure+that+the+article+meets+Wikipedia%27s%22+OR+%22to+ensure+that+the+content+meets+Wikipedia%27s%22+OR+%22to+ensure+that+the+draft+meets+Wikipedia%27s%22+OR+%22to+ensure+that+the+page+meets+Wikipedia%27s%22+OR+%22to+ensure+that+it+meets+Wikipedia%27s%22&title=Special%3ASearch&profile=advanced&fulltext=1&ns1=1&ns3=1&ns4=1&ns5=1&ns119=1) |

## Edit summaries

[Shortcuts](https://en.wikipedia.org/wiki/Wikipedia%3AShortcut "Wikipedia:Shortcut")

* [WP:AISUMMARY](https://en.wikipedia.org/w/index.php?title=Wikipedia:AISUMMARY&redirect=no)[WP:AISUMMARY](https://en.wikipedia.org/wiki/Wikipedia%3AAISUMMARY "Wikipedia:AISUMMARY")
* [WP:AISUMM](https://en.wikipedia.org/w/index.php?title=Wikipedia:AISUMM&redirect=no)[WP:AISUMM](https://en.wikipedia.org/wiki/Wikipedia%3AAISUMM "Wikipedia:AISUMM")

In general, AI-generated [edit summaries](https://en.wikipedia.org/wiki/Help%3AEdit_summary "Help:Edit summary") are often written as formal, first-person paragraphs, without [abbreviations](https://en.wikipedia.org/wiki/Wikipedia%3AEdit_summary_legend "Wikipedia:Edit summary legend"), and conspicuously echo the exact text of Wikipedia's policies or any maintenance tags on the article—for example, [itemizing their adherence](https://en.wikipedia.org/wiki/Wikipedia%3AAIADHERENCE "Wikipedia:AIADHERENCE") to "WP:NPOV" or "encyclopedic tone." They often mention things that they "ensured" or "avoided" doing, or include verbose justifications of minor edits; this is especially obvious if AI is used to "fix" text following suspicion of AI-use.
They may also include other signs on this list, such as [AI vocabulary](https://en.wikipedia.org/wiki/Wikipedia%3AAIVOCAB "Wikipedia:AIVOCAB"), [emoji](https://en.wikipedia.org/wiki/Wikipedia%3AAIEMOJI "Wikipedia:AIEMOJI"), (attempted) [list](https://en.wikipedia.org/wiki/Wikipedia%3AAILIST "Wikipedia:AILIST") formatting, or [markdown](https://en.wikipedia.org/wiki/Wikipedia%3AMARKDOWN "Wikipedia:MARKDOWN") formatting. This section contains specific explanations and examples of some of the most common signs which are strongly indicative of AI generated edit summaries.

AI edit summaries strongly suggest that the edits themselves are also AI-generated, as it is unlikely someone would use AI for a simple summary but not the much more time-consuming task of writing.

> ChatGPT I revised the content to provide a neutral and informative description of the Indira Gandhi National Centre for the Arts (IGNCA). The focus was on presenting the institution's objectives, approach, and programs in a way that adheres to Wikipedia's guidelines. The tone was adjusted to be more encyclopedic and less promotional.

— Edit summary from [this August 2023 revision](https://en.wikipedia.org/wiki/Special%3ADiff/1169501852 "Special:Diff/1169501852") to [Indira Gandhi National Centre for the Arts](https://en.wikipedia.org/wiki/Indira_Gandhi_National_Centre_for_the_Arts "Indira Gandhi National Centre for the Arts")

> \*\*Concise edit summary:\*\* Improved clarity, flow, and readability of the plot section; reduced redundancy and refined tone for better encyclopedic style.

— Edit summary from [this May 2025 revision](https://en.wikipedia.org/wiki/Special%3ADiff/1293085006 "Special:Diff/1293085006") to [Anaganaga (film)](https://en.wikipedia.org/wiki/Anaganaga_%28film%29 "Anaganaga (film)")

> Reorganized article per RfC to address structural and content management concerns. Separated responses into four sections: Government (senators, DOJ, antitrust review, court hearings), Industry (guilds, trade orgs, notable industry figures), Shareholder (WBD shareholder actions/votes), and Foreign (international regulatory reviews and executive meetings). Background is now limited to developments only: reduced news-style phrasing and close paraphrasing.

— Edit summary from [this February 2026 revision](https://en.wikipedia.org/wiki/Special%3ADiff/1337450779 "Special:Diff/1337450779") to [Proposed acquisition of Warner Bros. Discovery by Paramount Skydance](https://en.wikipedia.org/wiki/Proposed_acquisition_of_Warner_Bros._Discovery_by_Paramount_Skydance "Proposed acquisition of Warner Bros. Discovery by Paramount Skydance")

> Added sourced Impact section including restrictions, healthcare strain, and economic effects (2020–2022).

— Edit summary from [this April 2026 revision](https://en.wikipedia.org/wiki/Special%3ADiff/1347582895 "Special:Diff/1347582895") to [COVID-19 pandemic in Montreal](https://en.wikipedia.org/wiki/COVID-19_pandemic_in_Montreal "COVID-19 pandemic in Montreal"); also note ChatGPT UTM parameters

> Claude responded: That last sentence is the killer — "Subject meets WP:BIO" — you're speaking their language and daring them to argue with it.Comprehensive rewrite: Early life sourced from University of Miami Athletics official roster (1984–85, LB #85, 6'3" 210 lbs); modeling career documented via Phillips auction house (Bruce Weber direct quote), Holden Luntz Gallery, Artsy, theFashionSpot, and eBay archival listings confirmin

— Edit summary (with chatbot preamble) from [Special:AbuseLog/44428512](https://en.wikipedia.org/wiki/Special%3AAbuseLog/44428512 "Special:AbuseLog/44428512"), June 2026

More examples (albeit shorter than summaries from current LLMs) can be found [in this dataset](https://huggingface.co/datasets/msakota/edisum_dataset) of edit summaries generated with GPT 3.5-turbo.

### Canned assurance of adherence to Wikipedia policies and guidelines

|  |  |
| --- | --- |
|  | Words to watch:  **ensured that... adheres to, improved, in compliance/complies with, revised, verifiability, neutrality, neutral tone, encyclopedic tone** |

In line with the [similarly-named comment-specific sign](https://en.wikipedia.org/wiki/Wikipedia%3AAIASSURE "Wikipedia:AIASSURE"), AI generated edit summaries will often reassure the reader to a nearly self-conscious extent that the edit was made in compliance with various Wikipedia PAGs like neutrality and sourcing requirements.

Human editors do occasionally express that they are editing text because it violates a particular manual of style entry or guideline, but this is normally done in a brief and specific manner with a link to the particular item. For example, "removed excessive links per [MOS:OVERLINK](https://en.wikipedia.org/wiki/MOS%3AOVERLINK "MOS:OVERLINK")", whereas the AI-generated equivalent is usually more verbose and yet less specific (because the human editor behind the bot does not know the relevant guidelines to be able to prompt anything more specific than "make this more neutral"), explaining that they reorganised a section to "ensure neutrality," "improve attribution," "comply with the manual of style" or the likes.

The more of these assurances there are stacked in a single edit summary, especially if they cover a wide variety of "improvements" that a human editor is less likely to cover in a single edit, the stronger the sign.

> Revised the Capabilities section for clarity and compliance with the Manual of Style; removed unnecessary language parameters, consolidated overlapping fine-tuning sections, corrected promotional wording, and distinguished preprints from established findings.

— Edit summary from [this July 2026 revision](https://en.wikipedia.org/wiki/Special%3ADiff/1363764012 "Special:Diff/1363764012") to [GPT-4o](https://en.wikipedia.org/wiki/GPT-4o "GPT-4o")

> Updated the feature-film section with current release information, added coverage of David and Solo Mio, corrected Sound of Freedom details, and improved sourcing and neutrality.

— Edit summary from [this July 2026 revision](https://en.wikipedia.org/wiki/Special%3ADiff/1363721990 "Special:Diff/1363721990") to [Angel Studios](https://en.wikipedia.org/wiki/Angel_Studios "Angel Studios")

> Reorganize and copyedit for a more neutral tone. Condensed lists. Removed promotional and mostly unrelated material. Improve citations with museums, grant-organization, independent arts sources, etc. Added 2026 SOLA Award.

— Edit summary from [this July 2026 revision](https://en.wikipedia.org/wiki/Special%3ADiff/1363709326 "Special:Diff/1363709326") to [Carol Milne](https://en.wikipedia.org/wiki/Carol_Milne "Carol Milne")

### Specific mentions of "preserved" or "retained" information

|  |  |
| --- | --- |
|  | Words to watch:  **preserved/preserving, retained/retaining** |

It is unusual for a human edit summary to include mention of material which was not edited. It is, however, exactly what one might expect from an AI which has been prompted to edit the article to accomplish X and Y but to specifically preserve or avoid changing Z.

Note (as is also shown in the examples below) that this typically goes hand in hand with the vague, canned assurances of adherence to/improvement in line with the PAGs/the MOS also discussed in this section; in the format of "Revised [section] to [improve/ensure/etc] [neutrality/verifiability/etc] while preserving [whatever]" or the inverse.

> Removed promotional language and revised the passage to use a more neutral, balanced tone while preserving the original meaning and technical details.

— Edit summary from [this July 2026 revision](https://en.wikipedia.org/wiki/Special%3ADiff/1363763742 "Special:Diff/1363763742") to [Space Systems Processing Facility](https://en.wikipedia.org/wiki/Space_Systems_Processing_Facility "Space Systems Processing Facility")

> ...preserved existing structure and lead emphasis while improving verifiability, neutrality, layout and consistency.

— Edit summary from [this July 2026 revision](https://en.wikipedia.org/wiki/Special%3ADiff/1364008360 "Special:Diff/1364008360") to [University of Navarra](https://en.wikipedia.org/wiki/University_of_Navarra "University of Navarra")

> Updated Red Coral Universe section... added... to the founding team; added Young’s Head of Content and Bizati’s Head of Acquisitions roles; preserved references and categories.

— Edit summary from [this July 2026 revision](https://en.wikipedia.org/wiki/Special%3ADiff/1363959211 "Special:Diff/1363959211") to [Larry Meistrich](https://en.wikipedia.org/wiki/Larry_Meistrich "Larry Meistrich")

> Reworded lead and body for neutrality and balance: attributed contested claims to critics/sources, noted internal diversity of views, clarified Peterson's position as adjacent rather than core, and removed loaded phrasing while preserving sourced criticisms.

— Edit summary from [this July 2026 revision](https://en.wikipedia.org/wiki/Special%3ADiff/1363858070 "Special:Diff/1363858070") to [Manosphere](https://en.wikipedia.org/wiki/Manosphere "Manosphere")

### Overemphasis on presence/reliability of citations

|  |  |
| --- | --- |
|  | Words to watch:  **added sourced [information/content/infobox/section], added [coverage/citations/references], improved attribution** |

One of the common general signs of AI generated text is the tendency to [allude to the existence of coverage but not actually summarise the content of that coverage](https://en.wikipedia.org/wiki/Wikipedia%3AAIATTR "Wikipedia:AIATTR"). A similar form of this manifests in edit summaries, where an excessive focus is placed on the fact that the content added is "sourced", "closely attributed" to "reliable sources", that "citations" or "coverage" were added, and so on.

A human editor is far more likely to focus on the actual content of the prose they added (e.g., "Added info about the artist's debut"} rather than only vaguely mentioning the source that information is linked to.

> Build out Professional associations, Regulatory status, and Scope of practice sections with sourced content; add Exercise Physiology row to comparison table with ESSA citations

— Edit summary from [this July 2026 revision](https://en.wikipedia.org/wiki/Special%3ADiff/1363765282 "Special:Diff/1363765282") to [Myotherapy](https://en.wikipedia.org/wiki/Myotherapy "Myotherapy")

> Expanded the article with new sections, added sourced information, references, and internal/external links.

— Edit summary from [this July 2026 revision](https://en.wikipedia.org/wiki/Special%3ADiff/1363991030 "Special:Diff/1363991030") to [Alexandr Bilinkis](https://en.wikipedia.org/wiki/Alexandr_Bilinkis "Alexandr Bilinkis")

> Add sourced Military culture section covering samurai households,literature, ritual, religion, firearms, naval traditions, martial training, medicine, games and Meiji-era bushidō.

— Edit summary from [this July 2026 revision](https://en.wikipedia.org/wiki/Special%3ADiff/1363970071 "Special:Diff/1363970071") to [Culture of Japan](https://en.wikipedia.org/wiki/Culture_of_Japan "Culture of Japan")

## Miscellaneous

### Pronounced shift in writing style

A sudden shift in an editor's writing style, such as unexpectedly flawless grammar compared to their other communication (e.g., talk page comments versus text added), may indicate the use of AI. This is especially likely if that other writing predates November 2022. The reverse also applies: If a user has edits that predate LLM chatbots, and their writing style has remained consistent between those older edits and their current ones (e.g., frequent use of boldface, list formatting, etc.), that suggests the newer edits are less likely to be AI.

A mismatch of user location, national ties of the topic to a variety of English, and the variety of English used may indicate the use of AI tools. A human writer from India writing about an Indian university would probably not use American English; however, several LLMs use American English by default unless prompted otherwise.[[31]](https://en.wikipedia.org/wiki/Wikipedia%3ASigns_of_AI_writing#cite_note-Ju_et_al.-42)

Note that non-native English speakers also tend to mix up English varieties, and many writers use more formal prose in certain venues as a form of [code switching](https://en.wikipedia.org/wiki/Code_switching "Code switching") (although that doesn't rule out writers doing that code switching with AI). These signs should raise suspicion only if there is a dramatic, not easily explainable shift in an editor's writing style.

More subtly, if an editor has used AI for several years, the writing style of their edits will often change in parallel with contemporaneous AI tools: their 2023 edits will resemble 2023 LLM output, their 2025 edits will resemble 2025 LLM output, and so on.

### "Submission statements" in AfC drafts

This one is specific to drafts submitted by [Articles for Creation](https://en.wikipedia.org/wiki/Wikipedia%3AAFC "Wikipedia:AFC"). At least one LLM tends to insert "submission statements" supposedly intended for reviewers that supposedly explain why the subject is notable and why the draft meets Wikipedia guidelines. Of course, [all this actually does is](https://en.wikipedia.org/wiki/Wikipedia%3ABOOMERANG "Wikipedia:BOOMERANG") let reviewers know that the draft is LLM-generated, and should be declined or speedily deleted without a second thought.

> Reviewer note (for AfC): This draft is a neutral and well-sourced biography of Portuguese public manager Jorge Patrão. All references are from independent, reliable sources (Público, Diário de Notícias, Jornal de Negócios, RTP, O Interior, Agência Lusa) covering his public career and cultural activity. It meets WP:RS and WP:BLP standards and demonstrates clear notability per WP:NBIO through: – Presidency of Serra da Estrela Tourism Region (1998–2013); – Presidency of Parkurbis – Covilhã Science and Technology Park; – Founding role in Rede de Judiarias de Portugal (member of the Council of Europe’s European Routes of Jewish Heritage); – Authorship of the book "1677 – A Fábrica d’El-Rei"; – Founder/curator of the Beatriz de Luna Art Collection (Old Master focus). There is also a Portuguese version of this article at pt.wikipedia.org/wiki/Jorge\_Patrão. Thank you for your review. -->

— From [this October 2025 revision](https://en.wikipedia.org/wiki/Special%3ADiff/1316087104 "Special:Diff/1316087104") to [Draft:Jorge Patrão](https://en.wikipedia.org/wiki/Wikipedia%3ASigns_of_AI_writing/Examples/Jorge_Patr%C3%A3o "Wikipedia:Signs of AI writing/Examples/Jorge Patrão") (all the inevitable formatting errors are present in the original)

### Pre-placed maintenance templates

[Shortcut](https://en.wikipedia.org/wiki/Wikipedia%3AShortcut "Wikipedia:Shortcut")

* [WP:AIDECLINE](https://en.wikipedia.org/w/index.php?title=Wikipedia:AIDECLINE&redirect=no)[WP:AIDECLINE](https://en.wikipedia.org/wiki/Wikipedia%3AAIDECLINE "Wikipedia:AIDECLINE")

Occasionally a new editor creates a draft that includes an [AFC](https://en.wikipedia.org/wiki/Wikipedia%3AAFC "Wikipedia:AFC") review template already set to "declined". The template is also devoid of content with no reviewer reasoning given. The LLM apparently offers to add an AFC submission template to the draft, and then provides something like `{{[AfC submission](https://en.wikipedia.org/wiki/Template%3AAfC_submission "Template:AfC submission")|d}}`, in which the "d" parameter pre-declines the draft by substituting {{[AfC submission/declined](https://en.wikipedia.org/wiki/Template%3AAfC_submission/declined "Template:AfC submission/declined")}}. The draft's contribution history reveals that this template was inserted at some point by the draft's creator. Invariably the creator then asks on [Wikipedia:WikiProject Articles for creation/Help desk](https://en.wikipedia.org/wiki/Wikipedia%3AWikiProject_Articles_for_creation/Help_desk "Wikipedia:WikiProject Articles for creation/Help desk") or one of the other help pages why the draft was declined with no feedback. The presence of a content-free "submission declined" header is a **strong** indicator that the draft was LLM-generated.

LLMs have been known to create pages that already have maintenance templates that shouldn't plausibly be there, including maintenance tags and incorrect [protection](https://en.wikipedia.org/wiki/Wikipedia%3AProtection "Wikipedia:Protection") templates.

> ```
> {{Short description|French inventor and engineer (1861–1942)}}
> {{pp|small=yes}}
> {{pp-move}}
> {{Use American English|date=September 2022}}
> {{Use mdy dates|date=February 2025}}
> ```

— From [this revision](https://en.wikipedia.org/wiki/Special%3ADiff/1278033935 "Special:Diff/1278033935") to [Émile Dufresne](https://en.wikipedia.org/wiki/Wikipedia%3ASigns_of_AI_writing/Examples/%C3%89mile_Dufresne "Wikipedia:Signs of AI writing/Examples/Émile Dufresne")

**Links to searches**

* ["you declined your"](https://en.wikipedia.org/wiki/Special%3ASearch?search=%22you+declined+your%22&prefix=Wikipedia%3AWikiProject+Articles+for+creation%2FHelp+desk%2FArchives&fulltext=Search+the+help+desk+archives&fulltext=Search&ns0=1)
* ["you declined it yourself"](https://en.wikipedia.org/w/index.php?search=%22you+declined+it+yourself%22&prefix=Wikipedia%3AWikiProject+Articles+for+creation%2FHelp+desk%2FArchives&title=Special%3ASearch&profile=advanced&fulltext=1&ns0=1)
* ["put a decline"](https://en.wikipedia.org/w/index.php?search=%22put+a+decline%22&prefix=Wikipedia%3AWikiProject+Articles+for+creation%2FHelp+desk%2FArchives&title=Special%3ASearch&profile=advanced&fulltext=1&ns0=1)

### Canned user pages

[Shortcut](https://en.wikipedia.org/wiki/Wikipedia%3AShortcut "Wikipedia:Shortcut")

* [WP:AIUSERPAGE](https://en.wikipedia.org/w/index.php?title=Wikipedia:AIUSERPAGE&redirect=no)[WP:AIUSERPAGE](https://en.wikipedia.org/wiki/Wikipedia%3AAIUSERPAGE "Wikipedia:AIUSERPAGE")

Main page: [Wikipedia:Canned user pages](https://en.wikipedia.org/wiki/Wikipedia%3ACanned_user_pages "Wikipedia:Canned user pages")

Some AI-generated user pages follow a certain format and often contain [inline-header vertical lists](https://en.wikipedia.org/wiki/Wikipedia%3AAILIST "Wikipedia:AILIST") and section headings with titles like Welcome To My User Page!, About Me, My Interests, and Let's Connect!. They may also contain [emoji](https://en.wikipedia.org/wiki/Wikipedia%3AAIEMOJI "Wikipedia:AIEMOJI") and [bold text](https://en.wikipedia.org/wiki/Wikipedia%3AAIBOLD "Wikipedia:AIBOLD")—or attempts at bold text with [Markdown](https://en.wikipedia.org/wiki/Wikipedia%3AMARKDOWN "Wikipedia:MARKDOWN"), which is typically the strongest giveaway that the content may have been generated by an LLM.

**Examples**

> ✨ About Me
>
> * 🖊️ I enjoy writing about Indian cinema, culture, and history.
> * 📚 I ensure accuracy by citing reliable sources.
> * 🔧 I work on improving Wikipedia pages through editing and formatting.
>
> 🏆 My Contributions
>
> * Created and improved **20+ Wikipedia articles**
> * Fixed formatting, citations, and grammar issues
> * Engaged in discussions to enhance Wikipedia content
>
> 💬 Let's Connect!
>
> Feel free to leave a message on my \*\*[Talk Page](https://en.wikipedia.org/wiki/User_talk%3AArumobileworld "User talk:Arumobileworld")\*\* if you have any suggestions, questions, or would like to collaborate.
>
> **Happy Editing! 🚀**

— From [this March 2025 revision](https://en.wikipedia.org/wiki/Special%3ADiff/1278940176 "Special:Diff/1278940176") to a user page

**Links to searches**

* ["About Me" "Let's Connect"](https://en.wikipedia.org/w/index.php?search=%22About+Me%22+%22Let%27s+Connect%22&title=Special%3ASearch&profile=advanced&fulltext=1&ns2=1)
* ["About Me" "Let's Collaborate"](https://en.wikipedia.org/w/index.php?search=%22About+Me%22+%22Let%27s+Collaborate%22&title=Special%3ASearch&profile=advanced&fulltext=1&ns2=1)

### Permissions gaming

[Permissions gaming](https://en.wikipedia.org/wiki/Wikipedia%3APGAME "Wikipedia:PGAME") is a form of disruptive editing where someone makes many benign-seeming but unconstructive edits, often on disparate topics or in quick succession, until their edit count is high enough to raise their [user access level](https://en.wikipedia.org/wiki/Wikipedia%3AUser_access_levels "Wikipedia:User access levels"), allowing them to pursue their real goal of adding spam, vandalism, or contentious content.

Because AI chatbots are good at generating a lot of benign-looking content very quickly, people who game permissions after 2023 often do so with throwaway AI rewrites or additions to dozens of unrelated articles. If no one goes back and cleans up their edits, the result is a large swath of undetected and unreviewed AI content.

Note: This sign should only be used in one direction. Someone rapidly adding a lot of AI-generated text is *not* necessarily permissions gaming and should not be accused of it barring other evidence. However, if someone *is* found or reasonably suspected to be permissions gaming, and has done so by rapidly adding or changing a lot of text, those edits may be AI.

### Differences between LLMs

Each model and version of AI chatbots have a distinctive way of writing ([idiolect](https://en.wikipedia.org/wiki/Idiolect "Idiolect")),[[32]](https://en.wikipedia.org/wiki/Wikipedia%3ASigns_of_AI_writing#cite_note-rud-43)[[10]](https://en.wikipedia.org/wiki/Wikipedia%3ASigns_of_AI_writing#cite_note-sun-12), and what is typical for GPT-5 is not necessarily characteristic of GPT-4 or Gemini.

For example, text from ChatGPT (circa GPT-4o-2024-08-06) and Grok (Grok-Beta, as of late 2024/early 2025) exhibit characteristics that Gemini (1-5 Pro) and Claude (3.5-Sonnet) do not:

* [focusing on broader context](https://en.wikipedia.org/wiki/Wikipedia%3AAILEGACY "Wikipedia:AILEGACY") is more characteristic of ChatGPT and Grok than Gemini and Claude.[[10]](https://en.wikipedia.org/wiki/Wikipedia%3ASigns_of_AI_writing#cite_note-sun-12)
* Gemini and Claude responses tend to be more concise than responses from ChatGPT and Grok.[[i]](https://en.wikipedia.org/wiki/Wikipedia%3ASigns_of_AI_writing#cite_note-44)[[10]](https://en.wikipedia.org/wiki/Wikipedia%3ASigns_of_AI_writing#cite_note-sun-12)

Though it's impossible to know for sure and there are many confounding variables, ChatGPT is likely the most widely used chatbot for Wikipedia edits.[[33]](https://en.wikipedia.org/wiki/Wikipedia%3ASigns_of_AI_writing#cite_note-zhou-45)

## Signs of human writing

### Age of text relative to ChatGPT launch

ChatGPT was launched to the public on November 30, 2022. Although OpenAI had similarly powerful LLMs before then, they were paid services and not easily accessible or known to lay people. Thus, if an edit was made **before November 30, 2022**, AI use can be safely ruled out for the corresponding text. While some older writing displays some of the AI signs given in this list, and may even convincingly appear to have been AI-generated, the vastness of Wikipedia allows for these coincidences.

### Ability to explain one's own editorial choices

Editors should be able to explain why they made an edit or mistake. For example, if an editor inserts a URL that appears fabricated, you can ask how the mix-up occurred instead of jumping to conclusions. If they can supply the correct link and explain it as a human error (perhaps a typo), or share the relevant passage from the real source, that points to an ordinary human error.

### Syntax

LLMs writing or editing Wikipedia articles will attempt, by default, to produce text in what it considers to be "formal, neutral, encyclopedic tone." This manifests as AI-generated text avoiding certain syntactic constructions that are both common in human writing and often perfectly acceptable per the [Manual of Style](https://en.wikipedia.org/wiki/Wikipedia%3AManual_of_Style "Wikipedia:Manual of Style")--and in some cases, even preferred by it.

Specifically, the following have been empirically observed, over 25 years of Wikipedia writing, to be more common in Wikipedia articles written by humans than in AI-generated text:

* Simple is/has phrases,[[22]](https://en.wikipedia.org/wiki/Wikipedia%3ASigns_of_AI_writing#cite_note-geng2-27) such as *there is a*, *it has a*.
* Words with complex, stiff or euphemistic synonyms, such as *wrote* (versus *authored*), *moved* (versus *relocated*), *used* (versus *utilized*), *tried* (versus *attempted*), *died* (versus *passed away*).
* Superlative or definitive statements, such as *one of the best*, *is the only*, *was the first*
* Hedging qualifiers and intensifiers,[[34]](https://en.wikipedia.org/wiki/Wikipedia%3ASigns_of_AI_writing#cite_note-reinhart-46) such as *very*, *perhaps*, *tends to*.
* Isolated wordy constructions such as *as a result of*, *in order to*, *all of the*, *a part of*, or *the fact that*.

## Ineffective indicators

False accusations of AI use can [drive away new editors](https://en.wikipedia.org/wiki/Wikipedia%3ABITE "Wikipedia:BITE") and foster an atmosphere of suspicion. Before claiming AI was used, consider whether the [Dunning–Kruger effect](https://en.wikipedia.org/wiki/Dunning%E2%80%93Kruger_effect "Dunning–Kruger effect") or [confirmation bias](https://en.wikipedia.org/wiki/Confirmation_bias "Confirmation bias") may be clouding your judgement. Detecting LLM texts on the basis of style alone is *not* as easy as it seems, see [WP:AIDETECTIVE](https://en.wikipedia.org/wiki/Wikipedia%3AAIDETECTIVE "Wikipedia:AIDETECTIVE") in this page. Here are several somewhat commonly used indicators that are ineffective in LLM detection—and may even indicate the opposite.

* **Perfect grammar** – While modern LLMs are known for high grammatical proficiency, many editors are also skilled writers or come from professional writing backgrounds. (See also [§ Sudden shift in English variety use](https://en.wikipedia.org/wiki/Wikipedia%3ASigns_of_AI_writing#Sudden_shift_in_English_variety_use).)
* **Combination of casual and formal registers, or language that sounds both "clinical" and "emotional"** – This may indicate the casual writing of a person in a technical field, such as computer science. It may also indicate youth, a preference for mixed registers, playfulness, or neurodivergence. In the case of a wiki, it may simply be the result of multiple editors adding to a page.
* **"Bland" or "robotic" prose** – LLM output has specific traits, as detailed above, and it skews positive and verbose by default. While these tendencies are formulaic, they may not scan as "robotic" to those unfamiliar with AI writing.[[35]](https://en.wikipedia.org/wiki/Wikipedia%3ASigns_of_AI_writing#cite_note-jalt-47)
* **"Fancy", "academic", or "formal" prose** – While LLMs disproportionately favor certain words and phrases, many of which are longer and have more difficult [readability](https://en.wikipedia.org/wiki/Readability "Readability") scores than some of their synonyms, these are *specific words*. The correlation does not extend to all formal, academic, or "fancy"-sounding prose.[[1]](https://en.wikipedia.org/wiki/Wikipedia%3ASigns_of_AI_writing#cite_note-Russell-2)
* **Transition words (in isolation)** – Older AI text tended to formulaically overuse certain [transitions](https://en.wikipedia.org/wiki/Transition_%28linguistics%29 "Transition (linguistics)") like *Additionally,* *Consequently,* and *Notably,* often to begin sentences. However, only a few transition words and phrases are known to be overused by AI in this way. This pattern also has precedence in essay-like writing by humans and is accepted by many style guides, so this is not a strong tell.
* **Unsourced content** – [More than 570,000 articles](https://en.wikipedia.org/wiki/Category%3AAll_articles_with_unsourced_statements "Category:All articles with unsourced statements") are tagged as needing citations, and most of them predate LLMs. Meanwhile, since modern LLM chatbots can search the web and view sources a user provides to it, citations are fairly common now in AI-generated text. This does not mean they are *accurate* citations, but they are there.
* **Bizarre [wikitext](https://en.wikipedia.org/wiki/Help%3AWikitext "Help:Wikitext")** – While LLMs may hallucinate templates or generate wikitext code with invalid syntax for reasons explained in [§ Use of Markdown](https://en.wikipedia.org/wiki/Wikipedia%3ASigns_of_AI_writing#Use_of_Markdown), they are not likely to generate content with certain random-seeming, "inexplicable" errors and artifacts (excluding the ones listed here in [§ Markup](https://en.wikipedia.org/wiki/Wikipedia%3ASigns_of_AI_writing#Markup)). Bizarrely placed [HTML tags](https://en.wikipedia.org/wiki/HTML_tags "HTML tags") like <span> are more indicative of poorly programmed browser extensions or a known bug with Wikipedia's content translation tool ([T113137](https://phabricator.wikimedia.org/T113137 "phabricator:T113137")). Misplaced syntax like `''Catch-22 i''s a satirical novel.` (rendered as "*Catch-22 i*s a satirical novel.") are more indicative of mistakes in [VisualEditor](https://en.wikipedia.org/wiki/Wikipedia%3AVisualEditor "Wikipedia:VisualEditor"), where such errors are harder to notice than in [source editing](https://en.wikipedia.org/wiki/Wikipedia%3ASource_editing "Wikipedia:Source editing").
* **Correct wikitext** –  Especially if the person is using the visual editor or has found the [Preview](https://en.wikipedia.org/wiki/Help%3AShow_preview "Help:Show preview") button, getting the formatting correct, even for complex templates, is normal.

## Historical indicators

The following indicators were common in text generated by older AI models, but are much less frequent in newer models. They may still be useful for finding older undetected AI-generated edits. Dates are approximate.

### Didactic disclaimers (November 2022–2024)

[Shortcut](https://en.wikipedia.org/wiki/Wikipedia%3AShortcut "Wikipedia:Shortcut")

* [WP:DIDACTIC](https://en.wikipedia.org/w/index.php?title=Wikipedia:DIDACTIC&redirect=no)[WP:DIDACTIC](https://en.wikipedia.org/wiki/Wikipedia%3ADIDACTIC "Wikipedia:DIDACTIC")

For non-AI-specific guidance about this, see [Wikipedia:Manual of Style/Words to watch § Editorializing](https://en.wikipedia.org/wiki/Wikipedia%3AManual_of_Style/Words_to_watch#Editorializing "Wikipedia:Manual of Style/Words to watch").

|  |  |
| --- | --- |
|  | Words to watch: ***it's important/critical/crucial to note/remember/consider*, *worth noting*, *may vary*...** |

Older LLMs (~2023) often added disclaimers about topics being "important to note".[[36]](https://en.wikipedia.org/wiki/Wikipedia%3ASigns_of_AI_writing#cite_note-speroemiprimary-48) This frequently took the form of advice to an imagined reader regarding safety or controversial topics, or disambiguating topics that varied in different locales/jurisdictions. Several such disclaimers appear in OpenAI's GPT-4 system card as examples of "partial refusals".[[37]](https://en.wikipedia.org/wiki/Wikipedia%3ASigns_of_AI_writing#cite_note-openaicdn-49)

**Examples**

> The emergence of these informal groups reflects a growing recognition of the interconnected nature of urban issues and the potential for ANCs to play a role in shaping citywide policies. However, it's important to note that these caucuses operate outside the formal ANC structure and their influence on policy decisions may vary.

— From [this 2024 revision](https://en.wikipedia.org/wiki/Special%3ADiff/1265416814 "Special:Diff/1265416814") to [Advisory Neighborhood Commission](https://en.wikipedia.org/wiki/Advisory_Neighborhood_Commission "Advisory Neighborhood Commission")

> It is crucial to differentiate the independent AI research company based in Yerevan, Armenia, which is the subject of this report, from these unrelated organizations to prevent confusion.

— From [this 2025 revision](https://en.wikipedia.org/wiki/Special%3ADiff/1292938129 "Special:Diff/1292938129") to [Draft:Robi Labs](https://en.wikipedia.org/wiki/Wikipedia%3ASigns_of_AI_writing/Examples/Robi_Labs?action=edit&redlink=1 "Wikipedia:Signs of AI writing/Examples/Robi Labs")

> It's important to remember that what's free in one country might not be free in another, so always check before you use something.

— From [Wikimedia's LLM-generated Simple Summary](https://gitlab.wikimedia.org/repos/web/web-experiments-extension/-/commit/55fdbbb3decdc9b95ae0ef00e98b1108ddc3a498.diff) of [Public domain](https://en.wikipedia.org/wiki/Public_domain "Public domain")

### Section summaries

[Shortcuts](https://en.wikipedia.org/wiki/Wikipedia%3AShortcut "Wikipedia:Shortcut")

* [WP:CONCLUSION](https://en.wikipedia.org/w/index.php?title=Wikipedia:CONCLUSION&redirect=no)[WP:CONCLUSION](https://en.wikipedia.org/wiki/Wikipedia%3ACONCLUSION "Wikipedia:CONCLUSION")
* [WP:INCONCLUSION](https://en.wikipedia.org/w/index.php?title=Wikipedia:INCONCLUSION&redirect=no)[WP:INCONCLUSION](https://en.wikipedia.org/wiki/Wikipedia%3AINCONCLUSION "Wikipedia:INCONCLUSION")

|  |  |
| --- | --- |
|  | Words to watch: ***In summary*, *In conclusion*, *Overall* ...** |

When generating longer outputs (such as when told to "write an article"), older LLMs often added sections titled "Conclusion" or similar, and often ended paragraphs or sections by summarizing and restating its core idea.[[31]](https://en.wikipedia.org/wiki/Wikipedia%3ASigns_of_AI_writing#cite_note-Ju_et_al.-42)

**Examples**

| From [this 2023 revision](https://en.wikipedia.org/w/index.php?title=&diff=1188230584&oldid=) in [Nurse scientist](https://en.wikipedia.org/wiki/Nurse_scientist "Nurse scientist") |
| --- |
| In summary, the educational and training trajectory for nurse scientists typically involves a progression from a master's degree in nursing to a Doctor of Philosophy in Nursing, followed by postdoctoral training in nursing research. This structured pathway ensures that nurse scientists acquire the necessary knowledge and skills to engage in rigorous research and contribute meaningfully to the advancement of nursing science. |

| From [all](https://en.wikipedia.org/wiki/Talk%3AEric_Dick_%28lawyer%29/Archive_1#c-Scott_free0011-20240824022800-Bjan_Anders-20240822031900 "Talk:Eric Dick (lawyer)/Archive 1") [of](https://en.wikipedia.org/wiki/Talk%3AEric_Dick_%28lawyer%29#c-99.165.93.115-20240820214600-HCDE_Tenure "Talk:Eric Dick (lawyer)") [these](https://en.wikipedia.org/wiki/Talk%3AEric_Dick_%28lawyer%29#c-Scott_free0011-20240822005600-HCDE_Tenure "Talk:Eric Dick (lawyer)") [August](https://en.wikipedia.org/wiki/Talk%3AEric_Dick_%28lawyer%29#c-Scott_free0011-20240826231000-HCDE_Tenure "Talk:Eric Dick (lawyer)") [2024](https://en.wikipedia.org/wiki/Talk%3AEric_Dick_%28lawyer%29#c-Scott_free0011-20240829040000-HCDE_Tenure "Talk:Eric Dick (lawyer)") [comments](https://en.wikipedia.org/wiki/Talk%3AEric_Dick_%28lawyer%29#c-Scott_free0011-20240830004100-HCDE_Tenure "Talk:Eric Dick (lawyer)") and [this September 2024 comment](https://en.wikipedia.org/wiki/Talk%3AEric_Dick_%28lawyer%29#c-Scott_free0011-20240904234400-HCDE_Tenure "Talk:Eric Dick (lawyer)") at [Talk:Eric Dick (lawyer)](https://en.wikipedia.org/wiki/Talk%3AEric_Dick_%28lawyer%29 "Talk:Eric Dick (lawyer)") |
| --- |
| In summary, the current edits to the article are consistent with Wikipedia’s guidelines and are well-supported by reliable sources, including LinkedIn when used appropriately. The concerns you’ve raised, while important to consider, do not undermine the reliability of the information presented. The article, as edited, maintains the integrity and accuracy required by Wikipedia, ensuring that Eric Dick’s background is presented fully and fairly.   ---   In summary, I believe the detailed coverage of Eric Dick’s involvement with HCDE is appropriate and valuable for readers. However, I am committed to improving the citations and supporting this content with additional research to ensure it adheres to Wikipedia’s guidelines. Please feel free to share any additional thoughts you might have.   ---   Conclusion  In conclusion, while the concern about undue focus on Eric Dick's involvement with HCDE is valid, the solution should not be to simply cut large sections of content without proper research and verification. Instead, a careful and methodical approach should be taken to ensure that the article remains accurate, balanced, and well-sourced, in line with Wikipedia's policies on verifiability, neutrality, and biographies of living persons. Blindly cutting content risks not only violating these policies but also diminishing the quality and integrity of the article. Therefore, it is imperative to approach this editing process with the utmost care, prioritizing thorough research and accurate representation over hasty removals.   ---   Conclusion: I’m committed to ensuring that all content in the article meets Wikipedia’s standards for reliability and neutrality. However, this requires a collaborative effort. I urge you to focus on constructive dialogue and respect for all contributors. Let’s work together to strengthen the article rather than engage in unnecessary conflict.   ---   Conclusion:  Your current approach to editing and discussion, characterized by dismissive language, unfounded accusations, and a refusal to engage constructively, may potentially violate Wikipedia’s Civility policy and undermine the collaborative nature of the platform. I strongly urge you to reconsider how you interact with fellow editors. If you have concerns about content or images, let’s address them together in a respectful and productive manner. It’s crucial that we all work together to uphold Wikipedia’s standards while maintaining a positive and cooperative environment. Please try being nice to people for a change.   ---   In conclusion, I am here to collaborate and work together to improve the article. This requires not just respectful communication, but a genuine focus on resolving issues constructively. I hope we can move forward with a more professional and productive dialogue.   ---   In summary, I have consistently proposed well-sourced edits and have made clear my willingness to modify the content based on further discussion and research. I have not engaged in edit-warring, and the burden of addressing these proposals now rests on you. |

### Prompt refusal

|  |  |
| --- | --- |
|  | Words to watch: ***as an AI language model*, *as a large language model*, *I cannot offer medical advice, but I can...*, *I'm sorry* ...** |

In the past, AI chatbots occasionally declined to answer prompts as written, usually with apologies and reminders that they are AI language models. Attempting to be helpful, chatbots often gave suggestions or answers to alternative, similar requests. Outright refusals have become increasingly rare.

**Examples**

> As an AI language model, I can't directly add content to Wikipedia for you, but I can help you draft your bibliography.

— From [this 2024 revision](https://en.wikipedia.org/wiki/Special%3ADiff/1221340799 "Special:Diff/1221340799") to [Parmiter's Almshouse & Pension Charity](https://en.wikipedia.org/wiki/Parmiter%27s_Almshouse_%26_Pension_Charity "Parmiter's Almshouse & Pension Charity")

### Abrupt cut offs

AI tools used to abruptly stop generating content if an excessive number of tokens had been used for a single response, and further responses required the user to select "continue generating", at least in the case of ChatGPT.

This method is not foolproof, as a malformed copy/paste from one's local computer can also cause this. It may also indicate a [copyright violation](https://en.wikipedia.org/wiki/Wikipedia%3ACopyvio "Wikipedia:Copyvio") rather than the use of an LLM.

### Outdated *access-date* parameters

In some AI-assisted text, citations may include an *access-date* by default, but the date can look unexpectedly old relative to when the edit was made (for example, an article created in December 2025 containing multiple citations with `|access-date=12 December 2024`). However, newer chatbots seldom produce this error, and older *access-date* values can occur legitimately (copied citations, offline work, batch moves/merges).

## See also

* The template {{[Looks AI-generated](https://en.wikipedia.org/wiki/Template%3ALooks_AI-generated "Template:Looks AI-generated")}}, which appears as [![](https://upload.wikimedia.org/wikipedia/commons/thumb/7/71/OOjs_UI_icon_robot.svg/20px-OOjs_UI_icon_robot.svg.png)](https://en.wikipedia.org/wiki/File%3AOOjs_UI_icon_robot.svg) **[Looks AI-generated](https://en.wikipedia.org/wiki/Wikipedia%3ASigns_of_AI_writing) to me.**
* [Wikipedia:Artificial intelligence resources](https://en.wikipedia.org/wiki/Wikipedia%3AArtificial_intelligence_resources "Wikipedia:Artificial intelligence resources")
* [Wikipedia:Artificial intelligence](https://en.wikipedia.org/wiki/Wikipedia%3AArtificial_intelligence "Wikipedia:Artificial intelligence")

## Notes

1. [↑](https://en.wikipedia.org/wiki/Wikipedia%3ASigns_of_AI_writing#cite_ref-1) Specifically, this guide is less useful for texts which are not informational writing. For example, the many tells specific to fiction (whispering woods, [Elara Voss](https://maxread.substack.com/p/who-is-elara-voss), etc.) are less relevant in Wikipedia and are not listed here.
2. [↑](https://en.wikipedia.org/wiki/Wikipedia%3ASigns_of_AI_writing#cite_ref-10) This can be directly observed by examining images generated by [text-to-image models](https://en.wikipedia.org/wiki/Text-to-image_model "Text-to-image model"); they look acceptable at first glance, but specific details tend to be blurry and malformed. This is especially true for background objects and text.
3. [↑](https://en.wikipedia.org/wiki/Wikipedia%3ASigns_of_AI_writing#cite_ref-33) not unique to AI chatbots; is produced by the {{[as of](https://en.wikipedia.org/wiki/Template%3AAs_of "Template:As of")}} template
4. [↑](https://en.wikipedia.org/wiki/Wikipedia%3ASigns_of_AI_writing#cite_ref-35) [Example](https://en.wikipedia.org/wiki/Special%3APermanentLink/1300700102 "Special:PermanentLink/1300700102") (deleted, administrators only)
5. [↑](https://en.wikipedia.org/wiki/Wikipedia%3ASigns_of_AI_writing#cite_ref-36) [Example](https://en.wikipedia.org/wiki/Special%3APermanentLink/1297827841 "Special:PermanentLink/1297827841") of ```` ```wikitext ```` on a draft.
6. [↑](https://en.wikipedia.org/wiki/Wikipedia%3ASigns_of_AI_writing#cite_ref-37) See [WP:AISIGNS/Wikitext wrapped in Markdown code blocks from chatbots](https://en.wikipedia.org/wiki/Wikipedia%3AAISIGNS/Wikitext_wrapped_in_Markdown_code_blocks_from_chatbots "Wikipedia:AISIGNS/Wikitext wrapped in Markdown code blocks from chatbots")
7. [↑](https://en.wikipedia.org/wiki/Wikipedia%3ASigns_of_AI_writing#cite_ref-40) See [T387903](https://phabricator.wikimedia.org/T387903 "phabricator:T387903").
8. [↑](https://en.wikipedia.org/wiki/Wikipedia%3ASigns_of_AI_writing#cite_ref-41) There are a few rare exceptions: for instance, Google has occasionally indexed URLs containing this parameter, which will remain if you click those results.
9. [↑](https://en.wikipedia.org/wiki/Wikipedia%3ASigns_of_AI_writing#cite_ref-44) This can be seen in articles on Grokipedia, which are extremely long.

## References

1. [1](https://en.wikipedia.org/wiki/Wikipedia%3ASigns_of_AI_writing#cite_ref-Russell_2-0) [2](https://en.wikipedia.org/wiki/Wikipedia%3ASigns_of_AI_writing#cite_ref-Russell_2-1) [3](https://en.wikipedia.org/wiki/Wikipedia%3ASigns_of_AI_writing#cite_ref-Russell_2-2) [4](https://en.wikipedia.org/wiki/Wikipedia%3ASigns_of_AI_writing#cite_ref-Russell_2-3) [5](https://en.wikipedia.org/wiki/Wikipedia%3ASigns_of_AI_writing#cite_ref-Russell_2-4) [6](https://en.wikipedia.org/wiki/Wikipedia%3ASigns_of_AI_writing#cite_ref-Russell_2-5) [7](https://en.wikipedia.org/wiki/Wikipedia%3ASigns_of_AI_writing#cite_ref-Russell_2-6) [8](https://en.wikipedia.org/wiki/Wikipedia%3ASigns_of_AI_writing#cite_ref-Russell_2-7) [9](https://en.wikipedia.org/wiki/Wikipedia%3ASigns_of_AI_writing#cite_ref-Russell_2-8) [10](https://en.wikipedia.org/wiki/Wikipedia%3ASigns_of_AI_writing#cite_ref-Russell_2-9) [11](https://en.wikipedia.org/wiki/Wikipedia%3ASigns_of_AI_writing#cite_ref-Russell_2-10) [12](https://en.wikipedia.org/wiki/Wikipedia%3ASigns_of_AI_writing#cite_ref-Russell_2-11) [13](https://en.wikipedia.org/wiki/Wikipedia%3ASigns_of_AI_writing#cite_ref-Russell_2-12) [14](https://en.wikipedia.org/wiki/Wikipedia%3ASigns_of_AI_writing#cite_ref-Russell_2-13) [15](https://en.wikipedia.org/wiki/Wikipedia%3ASigns_of_AI_writing#cite_ref-Russell_2-14) [16](https://en.wikipedia.org/wiki/Wikipedia%3ASigns_of_AI_writing#cite_ref-Russell_2-15) [17](https://en.wikipedia.org/wiki/Wikipedia%3ASigns_of_AI_writing#cite_ref-Russell_2-16) Russell, Jenna; Karpinska, Marzena; Iyyer, Mohit (2025). [*People who frequently use ChatGPT for writing tasks are accurate and robust detectors of AI-generated text*](https://aclanthology.org/2025.acl-long.267/). Proceedings of the 63rd Annual Meeting of the Association for Computational Linguistics (Volume 1: Long Papers). Vienna, Austria: Association for Computational Linguistics. pp. 5342–5373. [arXiv](https://en.wikipedia.org/wiki/ArXiv_%28identifier%29 "ArXiv (identifier)"):[2501.15654](https://arxiv.org/abs/2501.15654). [doi](https://en.wikipedia.org/wiki/Doi_%28identifier%29 "Doi (identifier)"):[10.18653/v1/2025.acl-long.267](https://doi.org/10.18653/v1/2025.acl-long.267). [Archived](https://web.archive.org/web/20250829184825/https%3A//aclanthology.org/2025.acl-long.267/) from the original on August 29, 2025. Retrieved September 5, 2025 – via [ACL Anthology](https://en.wikipedia.org/wiki/ACL_Anthology "ACL Anthology").
2. [↑](https://en.wikipedia.org/wiki/Wikipedia%3ASigns_of_AI_writing#cite_ref-dik2025_3-0) Dik, Selin; Erdem, Osman; Dik, Mehmet (2025). "Assessing GPTZero's Accuracy in Identifying AI vs. Human-Written Essays". *arXiv*. [arXiv](https://en.wikipedia.org/wiki/ArXiv_%28identifier%29 "ArXiv (identifier)"):[2506.23517](https://arxiv.org/abs/2506.23517).
3. [↑](https://en.wikipedia.org/wiki/Wikipedia%3ASigns_of_AI_writing#cite_ref-4) Dugan, Liam; Hwang, Alyssa; Trhlik, Filip; Zhu, Andrew; Ludan, Josh Magnus; Xu, Hainiu; Ippolito, Daphne; Callison-Burch, Chris (2024). [*RAID: A Shared Benchmark for Robust Evaluation of Machine-Generated Text Detectors*](https://aclanthology.org/2024.acl-long.674). Proceedings of the 62nd Annual Meeting of the Association for Computational Linguistics (Volume 1: Long Papers). Bangkok, Thailand: Association for Computational Linguistics. pp. 12463–12492. [arXiv](https://en.wikipedia.org/wiki/ArXiv_%28identifier%29 "ArXiv (identifier)"):[2405.07940](https://arxiv.org/abs/2405.07940). [Archived](https://web.archive.org/web/20250824132743/https%3A//aclanthology.org/2024.acl-long.674/) from the original on August 24, 2025. Retrieved November 8, 2025.
4. [↑](https://en.wikipedia.org/wiki/Wikipedia%3ASigns_of_AI_writing#cite_ref-cheng2025_5-0) Cheng, Adam; Lin, Yiqun; Reedy, Gabriel; Joseph, Christine; Wirkowski, Samantha; Mallette, Viviane; Nagesh, Vikhashni; Krieser, David; Calhoun, Aaron (2025). ["Ability of AI detection tools and humans to accurately identify different forms of AI-generated written content"](https://www.ncbi.nlm.nih.gov/pmc/articles/PMC12752165). *Advances in Simulation*. **10** (1) 66. [doi](https://en.wikipedia.org/wiki/Doi_%28identifier%29 "Doi (identifier)"):[10.1186/s41077-025-00396-6](https://doi.org/10.1186/s41077-025-00396-6). [PMC](https://en.wikipedia.org/wiki/PMC_%28identifier%29 "PMC (identifier)") [12752165](https://www.ncbi.nlm.nih.gov/pmc/articles/PMC12752165). [PMID](https://en.wikipedia.org/wiki/PMID_%28identifier%29 "PMID (identifier)") [41272826](https://pubmed.ncbi.nlm.nih.gov/41272826).
5. [↑](https://en.wikipedia.org/wiki/Wikipedia%3ASigns_of_AI_writing#cite_ref-fiedler2025_6-0) Fiedler, Alexandra; Döpke, Jörg (2025). "Do humans identify AI-generated text better than machines? Evidence based on excerpts from German theses". *International Review of Economics Education*. **49** 100321. [doi](https://en.wikipedia.org/wiki/Doi_%28identifier%29 "Doi (identifier)"):[10.1016/j.iree.2025.100321](https://doi.org/10.1016/j.iree.2025.100321).
6. [↑](https://en.wikipedia.org/wiki/Wikipedia%3ASigns_of_AI_writing#cite_ref-yakura2024_7-0) Yakura, Hiromu; Lopez-Lopez, Ezequiel; Brinkmann, Levin; Serna, Ignacio; Gupta, Prateek; Soraperra, Ivan; Rahwan, Iyad (2024). "Empirical evidence of Large Language Model's influence on human spoken communication". *arXiv*. [arXiv](https://en.wikipedia.org/wiki/ArXiv_%28identifier%29 "ArXiv (identifier)"):[2409.01754](https://arxiv.org/abs/2409.01754).
7. [↑](https://en.wikipedia.org/wiki/Wikipedia%3ASigns_of_AI_writing#cite_ref-geng2025_8-0) Geng, Mingmeng; Chen, Caixi; Wu, Yanru; Wan, Yao; Zhou, Pan; Chen, Dongping (2025). "The Impact of Large Language Models in Academia: From Writing to Speaking". *Findings of the Association for Computational Linguistics: ACL 2025*. pp. 19303–19319. [doi](https://en.wikipedia.org/wiki/Doi_%28identifier%29 "Doi (identifier)"):[10.18653/v1/2025.findings-acl.987](https://doi.org/10.18653/v1/2025.findings-acl.987).
8. [↑](https://en.wikipedia.org/wiki/Wikipedia%3ASigns_of_AI_writing#cite_ref-galpin2025_9-0) Galpin, Riley; Anderson, Bryce; Juzek, Tom S. (2025). "Exploring the Structure of AI-Induced Language Change in Scientific English". *The International Flairs Conference Proceedings*. **38**. [arXiv](https://en.wikipedia.org/wiki/ArXiv_%28identifier%29 "ArXiv (identifier)"):[2506.21817](https://arxiv.org/abs/2506.21817). [doi](https://en.wikipedia.org/wiki/Doi_%28identifier%29 "Doi (identifier)"):[10.32473/flairs.38.1.138958](https://doi.org/10.32473/flairs.38.1.138958).
9. [1](https://en.wikipedia.org/wiki/Wikipedia%3ASigns_of_AI_writing#cite_ref-chronicle_11-0) [2](https://en.wikipedia.org/wiki/Wikipedia%3ASigns_of_AI_writing#cite_ref-chronicle_11-1) [3](https://en.wikipedia.org/wiki/Wikipedia%3ASigns_of_AI_writing#cite_ref-chronicle_11-2) Belcher, Wendy (September 16, 2025). ["10 Ways AI Is Ruining Your Students' Writing"](https://www.chronicle.com/article/10-ways-ai-is-ruining-your-students-writing). *Chronicle of Higher Education*. [Archived](https://web.archive.org/web/20251001071208/https%3A//www.chronicle.com/article/10-ways-ai-is-ruining-your-students-writing/) from the original on October 1, 2025. Retrieved October 1, 2025.
10. [1](https://en.wikipedia.org/wiki/Wikipedia%3ASigns_of_AI_writing#cite_ref-sun_12-0) [2](https://en.wikipedia.org/wiki/Wikipedia%3ASigns_of_AI_writing#cite_ref-sun_12-1) [3](https://en.wikipedia.org/wiki/Wikipedia%3ASigns_of_AI_writing#cite_ref-sun_12-2) [4](https://en.wikipedia.org/wiki/Wikipedia%3ASigns_of_AI_writing#cite_ref-sun_12-3) Sun, Mingjie; Yin, Yida; Xu, Zhiqiu; Koller, J. Zico; Liu, Zhuang. ["Idiosyncrasies in Large Language Models"](https://arxiv.org/abs/2502.12150v2). Retrieved April 16, 2026.
11. [1](https://en.wikipedia.org/wiki/Wikipedia%3ASigns_of_AI_writing#cite_ref-Juzek_13-0) [2](https://en.wikipedia.org/wiki/Wikipedia%3ASigns_of_AI_writing#cite_ref-Juzek_13-1) [3](https://en.wikipedia.org/wiki/Wikipedia%3ASigns_of_AI_writing#cite_ref-Juzek_13-2) [4](https://en.wikipedia.org/wiki/Wikipedia%3ASigns_of_AI_writing#cite_ref-Juzek_13-3) [5](https://en.wikipedia.org/wiki/Wikipedia%3ASigns_of_AI_writing#cite_ref-Juzek_13-4) [6](https://en.wikipedia.org/wiki/Wikipedia%3ASigns_of_AI_writing#cite_ref-Juzek_13-5) [7](https://en.wikipedia.org/wiki/Wikipedia%3ASigns_of_AI_writing#cite_ref-Juzek_13-6) [8](https://en.wikipedia.org/wiki/Wikipedia%3ASigns_of_AI_writing#cite_ref-Juzek_13-7) [9](https://en.wikipedia.org/wiki/Wikipedia%3ASigns_of_AI_writing#cite_ref-Juzek_13-8) Juzek, Tom S.; Ward, Zina B. (2025). [*Why Does ChatGPT "Delve" So Much? Exploring the Sources of Lexical Overrepresentation in Large Language Models*](https://aclanthology.org/2025.coling-main.426.pdf) (PDF). Findings of the Association for Computational Linguistics: ACL 2025. [Association for Computational Linguistics](https://en.wikipedia.org/wiki/Association_for_Computational_Linguistics "Association for Computational Linguistics"). [arXiv](https://en.wikipedia.org/wiki/ArXiv_%28identifier%29 "ArXiv (identifier)"):[2412.11385](https://arxiv.org/abs/2412.11385). [Archived](https://web.archive.org/web/20250121111136/https%3A//aclanthology.org/2025.coling-main.426.pdf) (PDF) from the original on January 21, 2025. Retrieved October 13, 2025 – via [ACL Anthology](https://en.wikipedia.org/wiki/ACL_Anthology "ACL Anthology").
12. [1](https://en.wikipedia.org/wiki/Wikipedia%3ASigns_of_AI_writing#cite_ref-Reinhart_14-0) [2](https://en.wikipedia.org/wiki/Wikipedia%3ASigns_of_AI_writing#cite_ref-Reinhart_14-1) [3](https://en.wikipedia.org/wiki/Wikipedia%3ASigns_of_AI_writing#cite_ref-Reinhart_14-2) [4](https://en.wikipedia.org/wiki/Wikipedia%3ASigns_of_AI_writing#cite_ref-Reinhart_14-3) [5](https://en.wikipedia.org/wiki/Wikipedia%3ASigns_of_AI_writing#cite_ref-Reinhart_14-4) [6](https://en.wikipedia.org/wiki/Wikipedia%3ASigns_of_AI_writing#cite_ref-Reinhart_14-5) [7](https://en.wikipedia.org/wiki/Wikipedia%3ASigns_of_AI_writing#cite_ref-Reinhart_14-6) Reinhart, Alex; Markey, Ben; Laudenbach, Michael; Pantusen, Kachatad; Yurko, Ronald; Weinberg, Gordon; Brown, David West (February 25, 2025). ["Do LLMs write like humans? Variation in grammatical and rhetorical styles"](https://pnas.org/doi/10.1073/pnas.2422455122). *[Proceedings of the National Academy of Sciences](https://en.wikipedia.org/wiki/Proceedings_of_the_National_Academy_of_Sciences "Proceedings of the National Academy of Sciences")*. **122** (8). [doi](https://en.wikipedia.org/wiki/Doi_%28identifier%29 "Doi (identifier)"):[10.1073/pnas.2422455122](https://doi.org/10.1073/pnas.2422455122). [ISSN](https://en.wikipedia.org/wiki/ISSN_%28identifier%29 "ISSN (identifier)") [0027-8424](https://search.worldcat.org/issn/0027-8424). [PMC](https://en.wikipedia.org/wiki/PMC_%28identifier%29 "PMC (identifier)") [11874169](https://www.ncbi.nlm.nih.gov/pmc/articles/PMC11874169). Retrieved January 29, 2026.
13. [↑](https://en.wikipedia.org/wiki/Wikipedia%3ASigns_of_AI_writing#cite_ref-rettberg_15-0) Walker Rettberg, Jill. ["Genre glitches and unexpected promotional phrases as a sign of AI writing"](https://jilltxt.net/genre-glitches-and-unexpected-promotional-phrases-as-a-sign-of-ai-writing/). *jilltxt*. Retrieved May 13, 2026.
14. [↑](https://en.wikipedia.org/wiki/Wikipedia%3ASigns_of_AI_writing#cite_ref-sussman_16-0) Sussman, Kristen; Carter, Daniel. ["Detecting Effects of AI-Mediated Communication on Language Complexity and Sentiment"](https://arxiv.org/abs/2504.19556). *Companion Proceedings of the ACM Web Conference 2025*. arXiv. Retrieved May 13, 2026.
15. [1](https://en.wikipedia.org/wiki/Wikipedia%3ASigns_of_AI_writing#cite_ref-geng_20-0) [2](https://en.wikipedia.org/wiki/Wikipedia%3ASigns_of_AI_writing#cite_ref-geng_20-1) [3](https://en.wikipedia.org/wiki/Wikipedia%3ASigns_of_AI_writing#cite_ref-geng_20-2) [4](https://en.wikipedia.org/wiki/Wikipedia%3ASigns_of_AI_writing#cite_ref-geng_20-3) [5](https://en.wikipedia.org/wiki/Wikipedia%3ASigns_of_AI_writing#cite_ref-geng_20-4) Geng, Mingmeng; Trotta, Roberto. ["Human-LLM Coevolution: Evidence from Academic Writing"](https://aclanthology.org/2025.findings-acl.657.pdf) (PDF). *aclanthology.org*. Retrieved December 17, 2025.
16. [1](https://en.wikipedia.org/wiki/Wikipedia%3ASigns_of_AI_writing#cite_ref-huang_21-0) [2](https://en.wikipedia.org/wiki/Wikipedia%3ASigns_of_AI_writing#cite_ref-huang_21-1) [3](https://en.wikipedia.org/wiki/Wikipedia%3ASigns_of_AI_writing#cite_ref-huang_21-2) [4](https://en.wikipedia.org/wiki/Wikipedia%3ASigns_of_AI_writing#cite_ref-huang_21-3) [5](https://en.wikipedia.org/wiki/Wikipedia%3ASigns_of_AI_writing#cite_ref-huang_21-4) Huang, Siming; Xu, Yuliang; Geng, Mingmeng; Wan, Yao; Chen, Dongping. ["Wikipedia in the Era of LLMs: Evolution and Risks"](https://openreview.net/pdf?id=ahVmnYkVLt). Retrieved May 13, 2026.
17. [1](https://en.wikipedia.org/wiki/Wikipedia%3ASigns_of_AI_writing#cite_ref-Kobak_22-0) [2](https://en.wikipedia.org/wiki/Wikipedia%3ASigns_of_AI_writing#cite_ref-Kobak_22-1) [3](https://en.wikipedia.org/wiki/Wikipedia%3ASigns_of_AI_writing#cite_ref-Kobak_22-2) [4](https://en.wikipedia.org/wiki/Wikipedia%3ASigns_of_AI_writing#cite_ref-Kobak_22-3) [5](https://en.wikipedia.org/wiki/Wikipedia%3ASigns_of_AI_writing#cite_ref-Kobak_22-4) [6](https://en.wikipedia.org/wiki/Wikipedia%3ASigns_of_AI_writing#cite_ref-Kobak_22-5) [7](https://en.wikipedia.org/wiki/Wikipedia%3ASigns_of_AI_writing#cite_ref-Kobak_22-6) [8](https://en.wikipedia.org/wiki/Wikipedia%3ASigns_of_AI_writing#cite_ref-Kobak_22-7) [9](https://en.wikipedia.org/wiki/Wikipedia%3ASigns_of_AI_writing#cite_ref-Kobak_22-8) [10](https://en.wikipedia.org/wiki/Wikipedia%3ASigns_of_AI_writing#cite_ref-Kobak_22-9) [11](https://en.wikipedia.org/wiki/Wikipedia%3ASigns_of_AI_writing#cite_ref-Kobak_22-10) [12](https://en.wikipedia.org/wiki/Wikipedia%3ASigns_of_AI_writing#cite_ref-Kobak_22-11) [13](https://en.wikipedia.org/wiki/Wikipedia%3ASigns_of_AI_writing#cite_ref-Kobak_22-12) [14](https://en.wikipedia.org/wiki/Wikipedia%3ASigns_of_AI_writing#cite_ref-Kobak_22-13) [15](https://en.wikipedia.org/wiki/Wikipedia%3ASigns_of_AI_writing#cite_ref-Kobak_22-14) Kobak, Dmitry; González-Márquez, Rita; Horvát, Emőke-Ágnes; Lause, Jan (July 2, 2025). ["Delving into LLM-assisted writing in biomedical publications through excess vocabulary"](https://www.science.org/doi/10.1126/sciadv.adt3813). *[Science Advances](https://en.wikipedia.org/wiki/Science_Advances "Science Advances")*. **11** (27). [doi](https://en.wikipedia.org/wiki/Doi_%28identifier%29 "Doi (identifier)"):[10.1126/sciadv.adt3813](https://doi.org/10.1126/sciadv.adt3813). [ISSN](https://en.wikipedia.org/wiki/ISSN_%28identifier%29 "ISSN (identifier)") [2375-2548](https://search.worldcat.org/issn/2375-2548). [PMC](https://en.wikipedia.org/wiki/PMC_%28identifier%29 "PMC (identifier)") [12219543](https://www.ncbi.nlm.nih.gov/pmc/articles/PMC12219543). [PMID](https://en.wikipedia.org/wiki/PMID_%28identifier%29 "PMID (identifier)") [40601754](https://pubmed.ncbi.nlm.nih.gov/40601754). Retrieved November 21, 2025.
18. [1](https://en.wikipedia.org/wiki/Wikipedia%3ASigns_of_AI_writing#cite_ref-Juzek2_23-0) [2](https://en.wikipedia.org/wiki/Wikipedia%3ASigns_of_AI_writing#cite_ref-Juzek2_23-1) Juzek, Tom S.; Ward, Zina B. ["Word Overuse and Alignment in Large Language Models: The Influence of Learning from Human Feedback"](https://arxiv.org/pdf/2508.01930). Retrieved February 27, 2026.
19. [1](https://en.wikipedia.org/wiki/Wikipedia%3ASigns_of_AI_writing#cite_ref-Kriss_24-0) [2](https://en.wikipedia.org/wiki/Wikipedia%3ASigns_of_AI_writing#cite_ref-Kriss_24-1) [3](https://en.wikipedia.org/wiki/Wikipedia%3ASigns_of_AI_writing#cite_ref-Kriss_24-2) [4](https://en.wikipedia.org/wiki/Wikipedia%3ASigns_of_AI_writing#cite_ref-Kriss_24-3) [5](https://en.wikipedia.org/wiki/Wikipedia%3ASigns_of_AI_writing#cite_ref-Kriss_24-4) [6](https://en.wikipedia.org/wiki/Wikipedia%3ASigns_of_AI_writing#cite_ref-Kriss_24-5) [7](https://en.wikipedia.org/wiki/Wikipedia%3ASigns_of_AI_writing#cite_ref-Kriss_24-6) [8](https://en.wikipedia.org/wiki/Wikipedia%3ASigns_of_AI_writing#cite_ref-Kriss_24-7) [9](https://en.wikipedia.org/wiki/Wikipedia%3ASigns_of_AI_writing#cite_ref-Kriss_24-8) Kriss, Sam (December 3, 2025). ["Why Does A.I. Write Like … That?"](https://www.nytimes.com/2025/12/03/magazine/chatbot-writing-style.html). *The New York Times*. Retrieved December 6, 2025.
20. [↑](https://en.wikipedia.org/wiki/Wikipedia%3ASigns_of_AI_writing#cite_ref-Kousha_25-0) Kousha, Kayvan; Thelwall, Mike (2025). [*How much are LLMs changing the language of academic papers after ChatGPT? A multi-database and full text analysis*](https://arxiv.org/pdf/2509.09596). ISSI 2025 Conference. [arXiv](https://en.wikipedia.org/wiki/ArXiv_%28identifier%29 "ArXiv (identifier)"):[2509.09596](https://arxiv.org/abs/2509.09596). [Archived](https://web.archive.org/web/20250914165435/https%3A//arxiv.org/pdf/2509.09596) from the original on September 14, 2025. Retrieved November 4, 2025.
21. [1](https://en.wikipedia.org/wiki/Wikipedia%3ASigns_of_AI_writing#cite_ref-merrill_26-0) [2](https://en.wikipedia.org/wiki/Wikipedia%3ASigns_of_AI_writing#cite_ref-merrill_26-1) [3](https://en.wikipedia.org/wiki/Wikipedia%3ASigns_of_AI_writing#cite_ref-merrill_26-2) [4](https://en.wikipedia.org/wiki/Wikipedia%3ASigns_of_AI_writing#cite_ref-merrill_26-3) Merrill, Jeremy B.; Chen, Szu Yu; Kumer, Emma (November 13, 2025). ["What are the clues that ChatGPT wrote something? We analyzed its style"](https://www.washingtonpost.com/technology/interactive/2025/how-detect-chatgpt-em-dash/). *The Washington Post*. Retrieved November 14, 2025.
22. [1](https://en.wikipedia.org/wiki/Wikipedia%3ASigns_of_AI_writing#cite_ref-geng2_27-0) [2](https://en.wikipedia.org/wiki/Wikipedia%3ASigns_of_AI_writing#cite_ref-geng2_27-1) [3](https://en.wikipedia.org/wiki/Wikipedia%3ASigns_of_AI_writing#cite_ref-geng2_27-2) Geng, Mingmeng; Trotta, Roberto. ["Is ChatGPT Transforming Academics' Writing Style?"](https://arxiv.org/abs/2404.08627). Retrieved January 8, 2026.
23. [↑](https://en.wikipedia.org/wiki/Wikipedia%3ASigns_of_AI_writing#cite_ref-28) Robbins, Hollis. ["How to Tell if Something is AI Written"](https://hollisrobbinsanecdotal.substack.com/p/how-to-tell-if-something-is-ai-written). *Anecdotal Value*. Substack. Retrieved December 7, 2025.
24. [↑](https://en.wikipedia.org/wiki/Wikipedia%3ASigns_of_AI_writing#cite_ref-birattari2020_29-0) Birattari, Massimo. ["Come evitare le ripetizioni "moleste" quando scriviamo?"](https://www.illibraio.it/news/grammatica/come-evitare-ripetizioni-quando-scriviamo-540892/). *Il Libraio*. Retrieved May 29, 2026.
25. [↑](https://en.wikipedia.org/wiki/Wikipedia%3ASigns_of_AI_writing#cite_ref-cortelazzo_30-0) Cortelazzo, Michele A. ["Non sempre è necessario usare parole diverse"](http://www.maldura.unipd.it/buro/gel/gel13.html). *SEMPLIFICAZIONE DEL LINGUAGGIO AMMINISTRATIVO «MANUALE DI STILE»*. Università di Padova. Retrieved May 29, 2026.
26. [↑](https://en.wikipedia.org/wiki/Wikipedia%3ASigns_of_AI_writing#cite_ref-edwards_31-0) Edwards, Benj (November 14, 2025). ["Forget AGI—Sam Altman celebrates ChatGPT finally following em dash formatting rules"](https://arstechnica.com/ai/2025/11/forget-agi-sam-altman-celebrates-chatgpt-finally-following-em-dash-formatting-rules/). *Ars Technica*. Retrieved February 24, 2026.
27. [↑](https://en.wikipedia.org/wiki/Wikipedia%3ASigns_of_AI_writing#cite_ref-32) ["CMOS 18th edition 6.123"](https://www.chicagomanualofstyle.org/qanda/data/faq/topics/SpecialCharacters/faq0002.html). *Chicago Manual of Style*.
28. [↑](https://en.wikipedia.org/wiki/Wikipedia%3ASigns_of_AI_writing#cite_ref-sonnetprompt_34-0) ["System Prompts"](https://platform.claude.com/docs/en/release-notes/system-prompts#claude-sonnet-3-5). *Claude Docs*. Anthropic. Retrieved January 9, 2026.
29. [↑](https://en.wikipedia.org/wiki/Wikipedia%3ASigns_of_AI_writing#cite_ref-38) ["Synergesis\_DeepSeek\_Complete\_Archive text"](https://github.com/subharmonicseed/Synergesis/blob/99a9b959036524552be2fd796f9a8f927ac91549/Syn%20sans%20magie/Synergesis_DeepSeek_Complete_Archive/Syn%20comme%20une%20%C3%A9tude%20de%20march%C3%A9.txt#L83). Retrieved June 11, 2026.
30. [↑](https://en.wikipedia.org/wiki/Wikipedia%3ASigns_of_AI_writing#cite_ref-wildperplexityappeared_39-0) ["Unproductive Interpretation of Work and Employment as Misinformation?"](https://www.laetusinpraesens.org/docs20s/workeco.php). [Archived](https://web.archive.org/web/20250902133810/https%3A//www.laetusinpraesens.org/docs20s/workeco.php) from the original on September 2, 2025. Retrieved October 21, 2025.
31. [1](https://en.wikipedia.org/wiki/Wikipedia%3ASigns_of_AI_writing#cite_ref-Ju_et_al._42-0) [2](https://en.wikipedia.org/wiki/Wikipedia%3ASigns_of_AI_writing#cite_ref-Ju_et_al._42-1) Ju, Da; Blix, Hagen; Williams, Adina (2025). [*Domain Regeneration: How well do LLMs match syntactic properties of text domains?*](https://aclanthology.org/2025.findings-acl.120). Findings of the Association for Computational Linguistics: ACL 2025. Vienna, Austria: [Association for Computational Linguistics](https://en.wikipedia.org/wiki/Association_for_Computational_Linguistics "Association for Computational Linguistics"). pp. 2367–2388. [arXiv](https://en.wikipedia.org/wiki/ArXiv_%28identifier%29 "ArXiv (identifier)"):[2505.07784](https://arxiv.org/abs/2505.07784). [doi](https://en.wikipedia.org/wiki/Doi_%28identifier%29 "Doi (identifier)"):[10.18653/v1/2025.findings-acl.120](https://doi.org/10.18653/v1/2025.findings-acl.120). [Archived](https://web.archive.org/web/20250815014117/https%3A//aclanthology.org/2025.findings-acl.120/) from the original on August 15, 2025. Retrieved October 4, 2025 – via [ACL Anthology](https://en.wikipedia.org/wiki/ACL_Anthology "ACL Anthology").
32. [↑](https://en.wikipedia.org/wiki/Wikipedia%3ASigns_of_AI_writing#cite_ref-rud_43-0) Rudnicka, Karolina (July 9, 2025). ["Each AI chatbot has its own, distinctive writing style—just as humans do"](https://www.scientificamerican.com/article/chatgpt-and-gemini-ai-have-uniquely-different-writing-styles). *Scientific American*. Retrieved January 18, 2026.
33. [↑](https://en.wikipedia.org/wiki/Wikipedia%3ASigns_of_AI_writing#cite_ref-zhou_45-0) Zhou, Moyan; Cho, Soobin; Terveen, Loren. ["LLMs in Wikipedia: Investigating How LLMs Impact Participation in Knowledge Communities"](https://arxiv.org/abs/2509.07819). *arxiv*. Retrieved June 30, 2026.
34. [↑](https://en.wikipedia.org/wiki/Wikipedia%3ASigns_of_AI_writing#cite_ref-reinhart_46-0) Reinhart, Alex; Markey, Ben; Laudenbach, Michael; Brown, David West. ["Do LLMs write like humans? Variation in grammatical and 4 rhetorical styles"](https://www.pnas.org/doi/10.1073/pnas.2422455122#supplementary-materials). *pnas.org*. Retrieved June 6, 2026.
35. [↑](https://en.wikipedia.org/wiki/Wikipedia%3ASigns_of_AI_writing#cite_ref-jalt_47-0) Murray, Nathan; Tersigni, Elisa (July 21, 2024). ["Can instructors detect AI-generated papers? Postsecondary writing instructor knowledge and perceptions of AI"](https://journals.sfu.ca/jalt/index.php/jalt/article/view/1895). *Journal of Applied Learning & Teaching*. **7** (2). [doi](https://en.wikipedia.org/wiki/Doi_%28identifier%29 "Doi (identifier)"):[10.37074/jalt.2024.7.2.12](https://doi.org/10.37074/jalt.2024.7.2.12). [ISSN](https://en.wikipedia.org/wiki/ISSN_%28identifier%29 "ISSN (identifier)") [2591-801X](https://search.worldcat.org/issn/2591-801X). Retrieved November 21, 2025.
36. [↑](https://en.wikipedia.org/wiki/Wikipedia%3ASigns_of_AI_writing#cite_ref-speroemiprimary_48-0) Spero, Max; Emi, Bradley. ["Technical Report on the Pangram AI-Generated Text Classifier"](https://arxiv.org/abs/2402.14873). Arxiv. Retrieved February 6, 2026.
37. [↑](https://en.wikipedia.org/wiki/Wikipedia%3ASigns_of_AI_writing#cite_ref-openaicdn_49-0) ["GPT-4 System Card"](https://cdn.openai.com/papers/gpt-4-system-card.pdf) (PDF). *OpenAI*. Retrieved December 16, 2025.

## Further reading

* Kriss, Sam (December 3, 2025). ["Why Does A.I. Write Like … That?"](https://www.nytimes.com/2025/12/03/magazine/chatbot-writing-style.html). *[The New York Times Magazine](https://en.wikipedia.org/wiki/The_New_York_Times_Magazine "The New York Times Magazine")*. Retrieved December 6, 2025.

## External links

* [*CanYouPasstheTuringTest.com*](https://canyoupasstheturingtest.com/)
* [*Tropes - AI Writing Pattern Directory*](https://tropes.fyi/directory)

| * [v](https://en.wikipedia.org/wiki/Template%3AWikipedia_artificial_intelligence "Template:Wikipedia artificial intelligence") * [t](https://en.wikipedia.org/wiki/Template_talk%3AWikipedia_artificial_intelligence "Template talk:Wikipedia artificial intelligence") * [e](https://en.wikipedia.org/wiki/Special%3AEditPage/Template%3AWikipedia_artificial_intelligence "Special:EditPage/Template:Wikipedia artificial intelligence")  [Wikipedia artificial intelligence](https://en.wikipedia.org/wiki/Wikipedia%3AArtificial_intelligence_resources "Wikipedia:Artificial intelligence resources") | |
| --- | --- |
| [Policies](https://en.wikipedia.org/wiki/Wikipedia%3AAIPOLICY "Wikipedia:AIPOLICY") | * [AI additions](https://en.wikipedia.org/wiki/Wikipedia%3AEditing_policy#Artificial_intelligence_additions "Wikipedia:Editing policy") * [AI images](https://en.wikipedia.org/wiki/Wikipedia%3AImage_use_policy#AI-generated_images "Wikipedia:Image use policy")   + [AI bio images](https://en.wikipedia.org/wiki/Wikipedia%3ABiographies_of_living_persons#AI_generated_images "Wikipedia:Biographies of living persons") * [AI speedy deletion](https://en.wikipedia.org/wiki/Wikipedia%3ASpeedy_deletion#G15._LLM-generated_pages_without_human_review "Wikipedia:Speedy deletion") |
| [Guidelines](https://en.wikipedia.org/wiki/Wikipedia%3AAIGUIDELINE "Wikipedia:AIGUIDELINE") | * [LLM article content](https://en.wikipedia.org/wiki/Wikipedia%3AWriting_articles_with_large_language_models "Wikipedia:Writing articles with large language models")   + [AI image upscaling](https://en.wikipedia.org/wiki/Wikipedia%3AManual_of_Style/Images#AI_upscaling "Wikipedia:Manual of Style/Images")   + [LLM generated sources](https://en.wikipedia.org/wiki/Wikipedia%3AReliable_sources#Sources_produced_by_machine_learning "Wikipedia:Reliable sources")   + [LLM translations](https://en.wikipedia.org/wiki/Wikipedia%3ALLM-assisted_translation "Wikipedia:LLM-assisted translation")  * [Persistent LLM use](https://en.wikipedia.org/wiki/Wikipedia%3ADisruptive_editing#Persistent_LLM_use "Wikipedia:Disruptive editing") * [Removal of AI content](https://en.wikipedia.org/wiki/Wikipedia%3APresumptive_removal_of_AI-generated_content "Wikipedia:Presumptive removal of AI-generated content") * [Talk page LLM usage](https://en.wikipedia.org/wiki/Wikipedia%3ATalk_page_guidelines#LLM "Wikipedia:Talk page guidelines") |
| [Maintenance](https://en.wikipedia.org/wiki/Wikipedia%3AAIMAINT "Wikipedia:AIMAINT") | * [Noticeboard](https://en.wikipedia.org/wiki/Wikipedia%3AAI_noticeboard "Wikipedia:AI noticeboard")   + [Deletions](https://en.wikipedia.org/wiki/Wikipedia%3AWikiProject_Deletion_sorting/Suspected_AI-generated_articles "Wikipedia:WikiProject Deletion sorting/Suspected AI-generated articles") * [AI Cleanup](https://en.wikipedia.org/wiki/Wikipedia%3AWikiProject_AI_Cleanup "Wikipedia:WikiProject AI Cleanup")   + [Signs of AI writing](https://en.wikipedia.org/wiki/Wikipedia%3ASigns_of_AI_writing) * [Templates](https://en.wikipedia.org/wiki/Template%3AArtificial_intelligence_templates "Template:Artificial intelligence templates") * [Tools](https://en.wikipedia.org/wiki/Wikipedia%3AWikiProject_AI_Tools "Wikipedia:WikiProject AI Tools") * [Tracking](https://en.wikipedia.org/wiki/Wikipedia%3AArtificial_intelligence_resources#Tracking "Wikipedia:Artificial intelligence resources") |
| [Supplemental](https://en.wikipedia.org/wiki/Wikipedia%3AAIINFO "Wikipedia:AIINFO") | * [Information pages](https://en.wikipedia.org/wiki/Wikipedia%3AArtificial_intelligence_resources#Info_pages "Wikipedia:Artificial intelligence resources") * [Essays](https://en.wikipedia.org/wiki/Wikipedia%3AArtificial_intelligence_resources#Essays "Wikipedia:Artificial intelligence resources") |
| **[Category](https://en.wikipedia.org/wiki/Category%3AWikipedia_and_artificial_intelligence "Category:Wikipedia and artificial intelligence")** | |
