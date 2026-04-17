# Logipad Documentation Style Guide

This guide defines the writing and formatting conventions for the Logipad Admin Guide and User Guide. Follow it when adding or editing any chapter to keep both guides consistent.

---

## Contents

1. [Audience and guides](#1-audience-and-guides)
2. [Tone and voice](#2-tone-and-voice)
3. [Product terminology](#3-product-terminology)
4. [Capitalization](#4-capitalization)
5. [Abbreviations and acronyms](#5-abbreviations-and-acronyms)
6. [Heading conventions](#6-heading-conventions)
7. [Inline formatting](#7-inline-formatting)
8. [Lists and procedures](#8-lists-and-procedures)
9. [Admonitions](#9-admonitions)
10. [Images and screenshots](#10-images-and-screenshots)
11. [Tables](#11-tables)
12. [Cross-references](#12-cross-references)
13. [Regulatory citations](#13-regulatory-citations)
14. [Known inconsistencies to resolve](#14-known-inconsistencies-to-resolve)

---

## 1. Audience and guides

| Guide | Primary audience | Subject matter |
|---|---|---|
| **Admin Guide** | EFB Administrators | MUI operations: users, library, infrastructure, Keycloak, contacts |
| **User Guide** | Flight crew (pilots, dispatchers) | Logipad iOS app: briefing, eForms, documentation, home screen |

Write each chapter for its guide's audience only. Do not mix admin-level instructions into the User Guide or assume flight crew has MUI access.

---

## 2. Tone and voice

- **Second person, imperative mood.** Address the reader as "you" and start steps with a verb.
  - Correct: `Click *Create new User*.`
  - Avoid: `The user should click the Create new User button.`
- **Active voice.** The actor does the action.
  - Correct: `Keycloak authenticates the user.`
  - Avoid: `The user is authenticated by Keycloak.`
- **Formal but direct.** No colloquialisms. Avoid filler phrases ("simply", "just", "easy", "of course").
- **Compliance-aware.** Aviation regulatory context is always present. State obligations clearly; do not soften mandatory requirements.

---

## 3. Product terminology

Use the exact spellings below. Do not abbreviate product names in body text (abbreviations are for parenthetical first use only).

| Term | Notes |
|---|---|
| **Logipad** | Always capital L. Never "LogiPad" or "logipad". |
| **EFB** | Electronic Flight Bag. Spell out on first use in a chapter: `Logipad EFB (Electronic Flight Bag)`. |
| **MUI** | Management User Interface. Spell out on first use: `Management User Interface (MUI)`. |
| **Keycloak** | Identity and access management component. Always capital K. |
| **Master User** | Pilot in Command role within Logipad. Always title case. |
| **First Officer** | Always title case. |
| **Dispatcher** | Always title case (when referring to the Logipad role). |
| **OFP** | Operational Flight Plan. Spell out on first use in a chapter. |
| **NOTAM / NOTAMs** | All caps. Plural adds only `s`, no apostrophe. |
| **QRH** | Quick Reference Handbook. Spell out on first use. |
| **MEL** | Minimum Equipment List. Spell out on first use. |
| **STD** | Scheduled Time of Departure. Spell out on first use. |
| **support@logipad.aero** | Support email address — monospace, no angle brackets. |

---

## 4. Capitalization

**Headings:** Sentence case — capitalize only the first word and proper nouns.
- Correct: `== Create a new user`
- Avoid: `== Create A New User`

**UI elements:** Title case, matching the label in the interface exactly.
- `*Create new User*`, `*Import Users*`, `*General > Users*`

**Crew roles:** Always title case.
- `Master User`, `First Officer`, `Dispatcher`

**Document states and configuration values:** Always in italics, as typed in the UI.
- `_Draft_`, `_Test_`, `_Prod_`, `_yes_`, `_no_`, `_none_`

**Regulatory standards:** All caps where the standard uses all caps.
- `EASA AMC 20-25`, `ORO.GEN.160`, `GDPR (EU) 2016/679`, `ARINC 633-3`

---

## 5. Abbreviations and acronyms

- Spell out on **first use within each chapter**, with the abbreviation in parentheses: `Management User Interface (MUI)`.
- On subsequent use within the same chapter, the abbreviation alone is fine.
- Do not re-introduce an abbreviation that has already been defined in that chapter.
- Do not define an abbreviation and then never use it.

---

## 6. Heading conventions

Use four levels of AsciiDoc headings. Do not skip levels.

```asciidoc
= Chapter title       ← level 1, one per file
== Major section      ← level 2
=== Subsection        ← level 3
==== Subsubsection    ← level 4 (use sparingly)
```

- The `=` (level 1) heading is the file title; it appears once at the top.
- Keep headings concise and descriptive. Favour action phrases for procedural sections (`== Export users`, `== Activate a briefing`).
- Do not use bold or inline formatting inside headings.

---

## 7. Inline formatting

| Purpose | AsciiDoc | Example |
|---|---|---|
| UI element names, button labels, field names | `*bold*` | `Click *Import Users*.` |
| Menu paths | `*bold*` with `>` separator | `Navigate to *General > Users*.` |
| Clickable buttons (HTML output) | `btn:[Label]` | `btn:[Cancel]` |
| Setting values, states, user-supplied input | `_italic_` | `Set *Separator* to _,_.` |
| Code, file extensions, technical strings | `` `monospace` `` | `Encoding must be \`UTF-8\`.` |
| URLs and paths in body text | `` `monospace` `` | `Upload to \`https://logipad.aero/api/\`.` |

**Numbered UI elements in screenshots:** use circled numerals (①, ②, ③) matching the annotation on the image, not plain numbers.

**Avoid** mixing formatting styles for the same type of element within or across chapters. For example, do not use plain text for a button label in one step and `*bold*` in another.

---

## 8. Lists and procedures

### Sequential steps — numbered list

Use a numbered list (`.`) for any procedure where order matters.

```asciidoc
. Navigate to *General > Users*.
. Click *Create new User*.
. Complete the required fields.
. Click *Save*.
```

### Non-sequential items — bulleted list

Use a bulleted list (`*`) for options, features, or items where order is irrelevant.

```asciidoc
* Drag and drop a file onto the upload zone.
* Click *Browse files* to open a system file picker.
```

### Nested lists

Indent with two spaces for one level deeper. Use `**` for a nested bullet under a bullet, or `..` for a nested step under a step.

```asciidoc
. First step:
  * Option A
  * Option B
. Second step
```

### Inserting an image inside a numbered list

Use the `+` list continuation marker to attach the image block without resetting the counter, then `+` again to resume.

```asciidoc
. Click the dropdown arrow (▼) next to *Create new User*.
. Select *Import Users*.
  The Import Users dialog opens.
+
[.center-caption]
.Import Users dialog
image::mui_import_users.png[Import Users dialog,50%,float="center",align="center"]
+
. Verify the CSV format settings.
```

---

## 9. Admonitions

Use admonitions sparingly — one per concept, not one per paragraph.

### Types and usage

| Type | When to use |
|---|---|
| `[WARNING]` | Regulatory obligation, security risk, data loss, compliance violation. |
| `[IMPORTANT]` | Mandatory operational procedure; failure leads to incorrect behaviour but not immediate safety risk. |
| `[NOTE]` | Factual constraint or clarification that would otherwise cause confusion. |
| `[TIP]` | Optional shortcut or helpful context; can safely be skipped. |

### Format

```asciidoc
[WARNING]
====
*Regulatory standard — short descriptive title:*
Body text. Use a full sentence. Can span multiple paragraphs or bullets.
====
```

- Admin guide WARNINGs that cite a standard: title format is `*EASA AMC 20-25 §X.X — action or topic:*`
- User guide WARNINGs without a specific standard: title format is `*Topic — short phrase:*` (as a definition list item using `::`)
- The title ends with a colon inside the bold marks.
- Do not use an admonition for information that fits naturally in body text.

### Examples

**Admin guide WARNING (standard cited):**
```asciidoc
[WARNING]
====
*EASA AMC 20-25 §5.2 — individual user accounts:*
Each crew member, dispatcher, or administrator must have a unique, individually assigned account.
Shared accounts are prohibited.
====
```

**User guide WARNING (no specific standard):**
```asciidoc
[WARNING]
====
Operational responsibility and sign-off::
Roles (Master/First Officer) and who may activate/finalize a briefing are defined by the operator's procedures and configuration.
Do not use a workflow that bypasses required approvals or sign-off steps.
====
```

---

## 10. Images and screenshots

### File naming

| Context | Prefix | Example |
|---|---|---|
| iOS app (User Guide) | `ios_` | `ios_Briefing_MasterUser_HKG_CVG.png` |
| Management UI (Admin Guide) | `mui_` | `mui_create_user_overview.png` |
| Branding / title page | `dd_` | `dd_title_page.svg` |

Use lowercase with underscores for MUI screenshots; use the MUI page name with underscores.

### Image syntax

```asciidoc
[.center-caption]
.Caption text — brief and descriptive
image::filename.png[Alt text,WIDTH%,float="center",align="center"]
```

- Always include the `[.center-caption]` role and a `.Caption` line.
- Alt text: one phrase describing what is shown (used by screen readers and PDF fallback). Do not repeat the caption verbatim.
- Width: use a percentage (see table below). Do not use pixel widths.

### Width guidelines

| Content | Width |
|---|---|
| Full-screen app view | `75%`–`85%` |
| Dialog or modal | `50%`–`60%` |
| Button or small UI element | `40%`–`50%` |
| Icon or badge | `25%`–`30%` |

### Placement

Place an image immediately after the step or paragraph it illustrates. If it falls inside a numbered list, use `+` continuation (see [section 8](#8-lists-and-procedures)).

---

## 11. Tables

Use a table when presenting two or more related attributes of multiple items side-by-side. Prefer a list when there is only one column of information.

### Syntax

```asciidoc
[cols="1,3",options="header"]
|===
| Column heading | Column heading

| Cell value
| Cell description

|===
```

- `cols` values are proportional weights, not pixel widths (`"1,3"` = narrow label, wide description).
- Always include `options="header"` so the first row renders as a header row.
- For tables where content determines width, use `[%autowidth%header]`.
- Leave a blank line between the header row and the first data row for readability in source.

---

## 12. Cross-references

Use `xref:` for links between chapters within the same guide.

```asciidoc
xref:chapters/admin/infrastructure.adoc#anchor-id[link text]
```

- Anchor IDs: lowercase, hyphen-separated, descriptive (`#keycloak-url`, `#library-upload`).
- Link text: short phrase that makes sense out of context ("see Infrastructure settings" not "click here").
- Do not link between the Admin Guide and the User Guide; they are separate output documents.

---

## 13. Regulatory citations

### How to cite

Cite the standard in the admonition title on first mention in a section; you do not need to repeat the full citation in the body text.

- EASA: `EASA AMC 20-25` (section: `EASA AMC 20-25 §5.2`)
- FAA: `FAA AC 120-76`
- ICAO: `ARINC 633-3`
- EU regulation: `GDPR (EU) 2016/679`
- Operations regulation: `ORO.GEN.160`, `ORO.GEN.120`

### Scope of compliance statements

- The Admin Guide includes compliance obligations for administrators (account management, audit trails, access control).
- The User Guide includes a single top-level IMPORTANT admonition per chapter that reminds crew this guide does not replace operator-approved procedures. Do not repeat this disclaimer in every subsection.

---

## 14. Known inconsistencies to resolve

The following inconsistencies exist in the current chapter files. Address them as chapters are edited — do not introduce new instances of these patterns.

| Issue | Current state | Target state |
|---|---|---|
| Action verbs in steps | Mix of `*Click*` (bold) and plain `Click` | Plain `Click`, `Tap`, `Navigate` — never bold the verb, only bold the UI target |
| `Figure:` label | `briefing.adoc` uses `Figure:[Briefing module]` prefix inline | Remove `Figure:` prefix; the `.Caption` line below the image is sufficient |
| Image width unit | Some images use `width=600` (pixels) | Replace with percentage (e.g. `75%`) |
| Admonition title style | Mix of `*Bold text:*` and `Term::` (definition list) | Admin guide uses `*Standard — title:*` bold; User Guide uses `Term::` definition list |
| Setting value formatting | Mix of `_italic_` and plain text for values | Always `_italic_` for configuration values and states |
| Role capitalization | Mix of `Master user` and `Master User` | Always title case: `Master User`, `First Officer`, `Dispatcher` |
| Incomplete sentences | `briefing.adoc` and `documentation.adoc` contain truncated sentences | Proofread and complete on next edit pass |
| Duplicate image captions | `documentation.adoc` has repeated caption text | Remove duplicates; each image must have a unique caption |
