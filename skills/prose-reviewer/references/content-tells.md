# AI-writing tells: content and substance
> Derived from [Wikipedia:Signs of AI writing](https://en.wikipedia.org/wiki/Wikipedia:Signs_of_AI_writing) (CC BY-SA 4.0), retrieved 2026-07-23; wiki links, citations, and page furniture stripped for reviewer-agent use. The full vendored copy with provenance is `signs-of-ai-writing.md`.

Patterns in *what the text says* — inflated significance, promotional framing, vague sourcing, hollow analysis. These are the highest-value tells because fixing them requires real rewriting, not word swaps.

LLMs (and artificial neural networks in general) use statistical algorithms to guess (infer) what should come next based on a large corpus of training material. It thus tends to regress to the mean; that is, the result tends toward the most statistically likely result that applies to the widest variety of cases. It can simultaneously be a strength and a "tell" for detecting AI-generated content.

For example, LLMs are usually trained on data from the internet in which famous people are generally described with positive, important-sounding language. Consequently, the LLM tends to omit specific, unusual, nuanced facts (which are statistically rare) and replace them with more generic, positive descriptions (which are statistically common). Thus the highly specific "inventor of the first train-coupling device" might become "a revolutionary titan of industry". It is like shouting louder and louder that a portrait shows a uniquely important person, while the portrait itself is fading from a sharp photograph into a blurry, generic sketch. The subject becomes simultaneously less specific and more exaggerated.

This statistical regression to the mean, a smoothing over of specific facts into generic statements, that could equally apply to many topics, makes AI-generated content easier to detect.

### Undue emphasis on significance, legacy, and broader trends

> Words to watch: ***stands/serves as*, *is a testament/reminder*, *a crucial/pivotal/vital/significant/key role/moment*, *underscores/highlights its importance/significance*, *reflects broader*, *symbolizing its ongoing/enduring/lasting*, *contributing to the*, *setting the stage for*, *marking/shaping the*, *represents/marks a shift*, *key turning point*, *evolving landscape*, *focal point*, *indelible mark*, *deeply rooted*,  ...**

LLM writing often puffs up the importance of the subject matter by adding statements about how arbitrary aspects of the topic represent or contribute to a broader topic. There is a distinct and easily identifiable repertoire of ways that it writes these statements.

**Examples**

> The Statistical Institute of Catalonia was officially established in 1989, marking a pivotal moment in the evolution of regional statistics in Spain. [...]  The founding of Idescat represented a significant shift toward regional statistical independence, enabling Catalonia to develop a statistical system tailored to its unique socio-economic context. This initiative was part of a broader movement across Spain to decentralize administrative functions and enhance regional governance.

> Kumba has long been an important center for trade and agriculture. [...] The establishment of road networks connecting Kumba to other parts of the Southwest Region, such as Mamfe and Buea, helped solidify its role as a regional hub.

Another common manifestation of this sign is AI chatbots situating an article subject amid broader "debates" or "discussions".

> The phenomenon has generated debate about authenticity, consent, and the psychological effects of digitally extending personhood.  [...]  Collectively, these works have shaped emerging policy discussions about ownership, consent, and dignity in digital resurrection technologies.  [...]  GriefBots have prompted broader reflection on mortality and memory in a digital age. They blur boundaries between life and data, raising philosophical questions about identity, authenticity, and what it means to “live on” through algorithms.

LLMs may even include these statements for even the most mundane of subjects like etymology or population data. Sometimes, they add hedging preambles acknowledging that the subject is of relatively low importance, before talking about its importance anyway.

> During the Spanish colonial period, the name *Bakunutan* was hispanized to *Bacnotan*, a modification reflected in official documents preserved in the National Archives in Manila. This etymology highlights the enduring legacy of the community's resistance and the transformative power of unity in shaping its identity.

— From this December 2024 revision to Bacnotan

> Though it saw only limited application, it contributes to the broader history of early aviation engineering and reflects the influence of French rotary designs on German manufacturers.

— From Draft:Goebel Goe II (July 2025)

When talking about biology (e.g., when asked to discuss an animal or plant species), LLMs tend to over-emphasize connections to the broader ecosystem or environment, even when those connections are tenuous or generic. LLMs also tend to belabor the species' conservation status and research and preservation efforts, even if the status is unknown and no serious efforts exist.

> Currently, there is no specific conservation assessment for *Lethrinops lethrinus* by the International Union for Conservation of Nature (IUCN). However, the general health of the Lake Malawi ecosystem is crucial for the survival of this and other endemic species. Factors such as overfishing, pollution, and habitat destruction could potentially impact their populations.

— From this July 2024 revision to Lethrinops lethrinus

> It plays a role in the ecosystem and contributes to Hawaii's rich cultural heritage. [...] Preserving this endemic species is vital not only for ecological diversity but also for sustaining the cultural traditions connected to Hawaii’s native flora.

— From this December 2024 revision to Nototrichium divaricatum

### Canned emphasis on notability, attribution, and media coverage

> Words to watch: ***independent coverage*, *local/regional/national/[country name] media outlets*, *music/business/tech outlets*, *trade publications*, *profiled in*, *written by a leading expert*, *active social media presence***

Similarly, LLMs act as if the best way to prove that a subject is notable is to hit readers over the head with claims of notability, often by listing sources that a subject has been covered in and specifying what kind of sources they are (e.g., trade publications, regional media, etc). They often inaccurately attribute their own superficial analyses to the source. This is more common in text from AI tools released in 2025 or later.

Human-written press releases have of course also cited news clippings for decades, but LLMs specifically asked to write a Wikipedia article often echo the exact wording of Wikipedia's guidelines, such as "independent coverage."

**Examples**

> She spoke about AI on CNN, and was featured in Vogue, Wired, Toronto Star, and other media. [...] Her insights have also been featured in \*Wired\*, \*Refinery29\*, and other prominent media outlets.

> Its significance is documented in archived school event programs and regional press coverage, including the \*Mesabi Daily News\*, which regularly reviewed performances held there.

> The subject has been profiled in multiple high-quality, independent, and widely-read outlets, including The Australian, SBS News, 7News, and coverage syndicated through the Associated Press—appearing in platforms like The Senior and Perth Now. These sources provide significant, substantial, secondary coverage, not trivial mentions or press releases.   ---   • Repeated national media coverage for both professional and advocacy work (reported by SBS, 7News, The Australian, etc.) • Leadership roles in international and national health campaigns (e.g., THINK Aorta ANZ and board member of Hearts4Heart) • National ambassador role for the National Heart Foundation of Australia, highlighted by multiple independent reports • Academic and economic contributions recognised by universities, specialist publications, and health system institutions (e.g., University of Sydney, Monash University, RANZCR) • Ongoing public presence in respected media and at speaking events over multiple years, including via independent news commentary, landmark survival stories, and national health initiatives Together, these factors clearly demonstrate significant, sustained, and verifiable coverage—meeting both WP:BIOSIGand WP:SIGCOV.

On Wikipedia specifically, LLMs often painstakingly emphasize their sources in the body text—even for trivial coverage, uncontroversial facts, or other situations where a human Wikipedia editor would be more likely to either provide an inline citation or no source at all.

**Examples**

> The restaurant has also been mentioned in ABC News coverage relating to incidents in the surrounding precinct, underscoring its role as a well-known late-night venue in the city [of Adelaide].

— Trivial coverage with attribution, from this August 2025 revision to The Original Pancake Kitchen; the reference added for this sentence did not exist.

In articles about people or entities that use social media, LLMs will often note that they "maintain an active social media presence" or something similar. This wording is particularly idiosyncratic to AI text and relatively uncommon on Wikipedia before ~2024.

**Examples**

> The mall maintains a strong digital presence, particularly on Instagram, where it actively shares the latest updates and events. Forum Kochi has consistently demonstrated excellence in digital promotions, with high-quality, engaging, and impactful video content playing a key role in its outreach.

— From this June 2025 revision to Forum Mall Kochi

### Superficial analyses

> Words to watch: ***highlighting/underscoring/emphasizing ...*, *ensuring ...*, *reflecting/symbolizing ...*, *contributing to ...*, *cultivating/fostering ...*, *encompassing ...*, *enhancing ...*, *valuable insights*, *align/resonate with*,**

AI chatbots tend to insert superficial analysis of information, often in relation to its significance, recognition, or impact. This is often done by attaching a present participle ("-ing") phrase at the end of sentences, sometimes with vague attributions to third parties (see below).

For the purpose of Wikipedia, such comments are usually synthesis or unattributed opinions. Newer chatbots with retrieval-augmented generation (for example, an AI chatbot that can search the web) may attach these statements to named sources—e.g., "Roger Ebert highlighted the lasting influence"—regardless of whether those sources say anything close.

**Examples**

— From this June 2023 revision to Douéra:
> As of the April 2008 census, the population of Douera stood at approximately 56,998 inhabitants, creating a lively community within its borders. Situated in the central-north region of the country, Douera enjoys close proximity to the capital city, Algiers, further enhancing its significance as a dynamic hub of activity and culture. With its coastal charm and convenient location, Douera captivates both residents and visitors alike, offering a diverse range of experiences against the backdrop of Algeria's stunning natural beauty.

> It holds a pivotal place in the East Central Railway Zone of Indian Railways, serving as a major railway hub with historical significance. The station has 1,676 mm (5 ft 6 in) broad gauge along with 8 tracks and 6 platforms. [...] Historically, it has been crucial for linking Darbhanga with significant cities like Delhi, Patna, and Kolkata, facilitating the movement of passengers and goods. The station has supported various services, including passenger trains and express trains like the Satyagrah Express and Mithila Express, contributing to the socio-economic development of the region. [...] Over the years, Darbhanga Junction has seen several upgrades and modernization efforts aimed at improving facilities and operational efficiency, reflecting its continued relevance in the regional and national transportation landscape.

> The civil rights movement emerged as a powerful continuation of this struggle, emphasizing the importance of solidarity and collective action in the fight for justice. This historical legacy has influenced contemporary African-American families, shaping their values, community structures, and approaches to political engagement. Economically, the enduring impacts of systemic inequality have led to both challenges and innovations within African-American communities, driving a commitment to empowerment and social change that echoes through generations.

> Situated just a few miles from the U.S.-Mexico border—a line that often represents separation and division—the temple stands as a counter-symbol, emphasizing unity, togetherness, and transcendent faith. In a region where many families and communities span both countries, the temple fosters a sense of connection and shared purpose. Through its inclusive design and symbolic features, the McAllen Texas Temple is seen as a bridge across divides, embodying the spirit of unity that underlies its sacred purpose. Its bilingual monument sign, with inscriptions in both English and Spanish, underscores its role in bringing together Latter-day Saints from the United States and Mexico.  The temple’s architectural and decorative elements are thoughtfully imbued with local symbolism, reflecting the rich culture and landscape of the Rio Grande Valley. Citrus blossom motifs, seen throughout the exterior and interior, celebrate the area’s agricultural roots and its vital citrus industry. The temple’s color palette of blue, green, and gold resonates with the region’s natural beauty, symbolizing Texas bluebonnets, the Gulf of Mexico, and the diverse Texan landscapes. These colors and patterns evoke enduring faith and resilience, qualities that resonate deeply within this close-knit, cross-border community.  In design and structure, the McAllen Texas Temple honors the Spanish colonial heritage that has historically shaped the area. By incorporating these architectural elements, the temple connects to both the Latin American influences and the historic roots of the border region, creating a space where the past and present come together.

> These works are now part of the \*\*Collections of the National Museum of Education - Réseau Canopé (France)\*\*, highlighting their historical and pedagogical significance.  His influence persists in more recent studies. In 2010, *Les néologismes dans l'hebdomadaire L'Express* (1980) was cited in the *Proceedings of the 1st International Congress on Neology in Romance Languages* [...] demonstrating the ongoing relevance of his research on lexical evolution. [...] In 2004, the *Cahiers de lexicologie* (issues 84-87), published by the CNRS, cited the *Grammaire Blois*, confirming its relevance in modern research. [...]  These citations, spanning more than six decades and appearing in recognized academic publications, illustrate Blois' lasting influence in computational linguistics, grammar, and neology.  Fridrichová analyzes the distinction made by Blois and Bar between acronyms, abbreviations, and truncations, emphasizing their critical view on the impact of truncations in the French language.  [...]  Fridrichová highlights that Blois and Bar perceive truncations as a \*\*distortion of the language rather than an enrichment\*\*, a perspective that still fuels linguistic debates today. This citation demonstrates the \*\*enduring relevance of Blois's work in modern linguistic studies\*\* and its \*\*critical reception by researchers\*\*.
### Promotional and advertisement-like language

> Words to watch: ***boasts a*, *vibrant*, *rich*, *profound*, *enhancing*, *showcasing*, *exemplifies*, *commitment to*, *natural beauty*, *nestled*, *in the heart of*, *groundbreaking*, *renowned*, *featuring*, *diverse array*,  ...**

LLMs have serious problems keeping a neutral tone. Even when prompted to use an encyclopedic style, their output will often tend toward advertisement-like writing, or like the prose of a travel guide. This may happen when generating new text or rewriting existing text: for instance, an edit summary claiming a rewrite "removed promotional tone" while actually introducing it. This may also happen when editors are not deliberately trying to advertise a subject.

Note: Not all promotional or spammy writing is AI-generated. LLMs tend to over-use the same set of promotional phrases no matter what the topic. Also, older LLMs (e.g., GPT-4) tend to output more blatantly positive text than newer LLMs, which are more subtly positive and tend to avoid obviously superlative statements like "the best."

#### Subtypes

When writing about something that could be considered "cultural heritage" (even Japan's electronics industry), LLMs constantly remind the reader of its importance.

— From this June 2023 revision to Alamata (woreda):
> Nestled within the breathtaking region of Gonder in Ethiopia, Alamata Raya Kobo stands as a vibrant town with a rich cultural heritage and a significant place within the Amhara region. From its scenic landscapes to its historical landmarks, Alamata Raya Kobo offers visitors a fascinating glimpse into the diverse tapestry of Ethiopia. In this article, we will explore the unique characteristics that make Alamata Raya Kobo a town worth visiting and shed light on its significance within the Amhara region.

— From this July 2025 revision to Tamil Nadu Tourism Development Corporation:
> TTDC acts as the gateway to Tamil Nadu’s diverse attractions, seamlessly connecting the beginning and end of every traveller's journey. It offers dependable, value-driven experiences that showcase the state’s rich history, spiritual heritage, and natural beauty.

When writing about people or companies, LLMs will often adopt a press-release or commercial-esque tone.

> These projects align with KQ's goals of reducing its environmental footprint, improving operational efficiency, and fostering community development through job creation. CEO Allan Kilavuka emphasized the airline's commitment to sustainability, customer focus, and Africa's prosperity through responsible corporate practices.

> The SOLLEI’s exterior design communicates a powerful emotional presence, staying true to Cadillac's signature bold proportions. Its low, elongated silhouette is highlighted by a wide stance and an extended coupe door, which enhances accessibility to the spacious rear cabin. Smooth, uninterrupted surfaces and a pronounced A-line accentuate the vehicle’s overall length, while a sleek, low tail imparts a sense of refined dynamism. A mid-body line runs seamlessly from the headlamps to the taillights, reinforcing the car’s cohesive and elegant design. Traditional door handles have been replaced with discrete buttons, preserving the vehicle’s clean and modern profile. In a nod to Cadillac’s legacy of bold color choices, the exterior is finished in "Manila Cream"—a distinctive hue originally offered in 1957 and 1958. This heritage color has been thoughtfully revived and hand-painted by Cadillac artisans, showcasing the brand’s dedication to craftsmanship and historical reverence.

### Vague attributions and overgeneralization of opinions

> Words to watch: ***Industry reports*, *Observers have cited*, *Experts argue*, *Some critics argue*, *several sources/publications* (when only few sources are cited), *such as* (before exhaustive word lists),  ...**

AI chatbots tend to attribute opinions or claims to some vague authority—a practice called weasel wording.

**Examples**

> Due to its unique characteristics, the Haolai River is of interest to researchers and conservationists. Efforts are ongoing to monitor its ecological health and preserve the surrounding grassland environment, which is part of a larger initiative to protect China’s semi-arid ecosystems from degradation.

— From this June 2025 revision to Haolai River

> The Kwararafa (Kororofa) confederacy is described in scholarship as a shifting Benue valley coalition led by Jukun groups and incorporating a range of Middle Belt peoples. Because much of the historical record derives from Hausa chronicles, Bornu sources and oral tradition, modern researchers treat Kwararafa as a fluid political and cultural formation rather than a fixed state.

— From this November 2025 revision to Kwararafa Confederacy

AI chatbots also commonly exaggerate the quantity of sources that these opinions are attributed to. They may present views from one or two sources as widely held (often combined with the vague attributions above), mention the existence or opinion of multiple "reviewers" or "scholars" while only citing one person, or imply that lists of examples are non-exhaustive when the sources give no indication that other examples exist.

**Examples**

> While Pakistan was not directly named, the reference to cross-border terrorism, according to Indian sources, was widely interpreted as aimed at Islamabad.

— From this July 2025 revision to BRICS

> Toy industry publications such as *The Toy Insider* and *Mojo Nation* have presented Rubik's WOWCube as a STEM-oriented platform that brings the Rubik's Cube "into the future" with motion controls and an open software ecosystem.

— From this December 2025 revision to Rubik's WOWCube.

### Outline-like conclusions about challenges and future prospects

> Words to watch: ***Despite its... faces several challenges...*, *Despite these challenges*, *Challenges and Legacy*, *Future Outlook* ...**

Many LLM-generated Wikipedia articles include a "Challenges" section, which typically begins with a sentence like "Despite its [positive/promotional words], [article subject] faces challenges..." and ends with either a vaguely positive assessment of the article subject, or speculation about how ongoing or potential initiatives could benefit the subject. Such paragraphs usually appear at the end of articles with a rigid outline structure, which may also include a separate section for "Future Prospects."

Note: This sign is about the rigid formula, not simply the mention of challenges or challenging.

**Examples**

> Challenges and Future Directions  As the global economy continues to evolve, international economic law faces new challenges and opportunities. [...] The future of international economic law lies in its ability to adapt to these emerging trends and continue to facilitate a stable and equitable global economic order.

— From this January 2024 revision to Hydrocarbon economy:
> The future of hydrocarbon economies faces several challenges, including[...] This section would speculate on potential developments and the changing landscape of global energy.

— From this April 2024 revision to Korattur:
> Despite its industrial and residential prosperity, Korattur faces challenges typical of urban areas, including[...] With its strategic location and ongoing initiatives, Korattur continues to thrive as an integral part of the Ambattur industrial zone, embodying the synergy between industry and residential living.

> Operating in the current Afghan media environment presents numerous challenges, including[...] Despite these challenges, Amu TV has managed to continue to provide a vital service to the Afghan population​​.

> Despite their promising applications, pyroelectric materials face several challenges that must be addressed for broader adoption. One key limitation is[...] Despite these challenges, the versatility of pyroelectric materials positions them as critical components for sustainable energy solutions and next-generation sensor technologies.

— From this March 2025 revision to Panama Canal:
> Despite its success, the Panama Canal faces challenges, including[...] Future investments in technology, such as automated navigation systems, and potential further expansions could enhance the canal’s efficiency and maintain its relevance in global trade.

> For example, while the methodology supports transdisciplinary collaboration in principle, applying it effectively in large, heterogeneous teams can be challenging. [...]  SCE continues to evolve in response to these challenges.

> Sociology, sustainability, and future challenges  The main contemporary challenge facing the fashion industry in Spain is its environmental impact, stemming from the production volume of fast fashion. [...]  Complementing this, the sector relies on technological research centres, such as the Textile Technology Institute (Aitex) in the Valencian Community, to develop patents for fibre-to-fibre chemical recycling, eco-design processes, and low-water-impact dyeing. These advancements aim to reduce dependence on petroleum-derived synthetic fibres and virgin cotton, marking the sector's mandatory transition towards sustainable and traceable business models for the coming decades.

### Leads treating Wikipedia lists or broad article titles as proper nouns

In AI-generated articles about topics with a title that is not a proper name, such as a list, the first sentence of the lead may introduce or define the article's title as if it were a standalone real-world entity. While the MOS does allow such titles to be included at the beginning of the lead "in a natural way", these AI leads tend not to be so natural.

**Examples**

> **Catchment area (health)** refers to the geographic area from which a health facility, such as a hospital or clinic, draws its patients.

— From this October 2024 revision to now-deleted article Catchment area (health)

> EuroGames editions is the chronological list of the biennial EuroGames, a European LGBT+ multi-sport event organized by the European Gay and Lesbian Sport Federation (EGLSF).

— From this July 2025 revision to EuroGames editions

> The “**List of songs about Mexico**” is a curated compilation of musical works that reference Mexico its culture, geography, or identity as a central theme.

— From this July 2025 revision to List of songs about Mexico
