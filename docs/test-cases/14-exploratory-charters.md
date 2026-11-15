# Exploratory Charters

A charter is a time-boxed session with a mission. The tester explores freely inside it and notes every problem with the bug template ([test-plan §11.2](../test-plan.md#112-bug-report)). In this table, **Steps** is the mission and **Expected** is what to note. Format: [README](README.md#3-case-format).

| ID | Title | Type | Pri | Run on | Auto | Pre-conditions / Data | Steps | Expected | Source |
|---|---|---|---|---|---|---|---|---|---|
| CH-01 | Odd input everywhere | EDGE | P2 | DEVICE | ✋ | Mock build; 60 minutes | Break every text field. Paste emoji, Arabic and Bangla text, 10 000 characters, zero-width spaces, spaces around values, line breaks | Crashes, overflow, text changed without telling, anything sent that should have been refused | §12.1, §13 |
| CH-02 | Fast and repeated taps | WORST | P2 | DEVICE | ✋ | Mock build; 45 minutes | Make the app send twice. Double and triple taps, taps while loading, tab switches during requests | Any request sent twice (a check, a report, a retail user), stuck loading, a frozen screen | §8.3 |
| CH-03 | Flaky network | NET | P2 | DEVICE | ✋ | Real phone; mock or staging; 60 minutes | Lose the connection at the worst moment. Airplane mode at random points of every flow; a walk through weak signal | Wrong or missing messages, no recovery, doubled checks or reports, logouts that should not happen | §15.4 |
| CH-04 | Interruptions | WORST | P3 | DEVICE | ✋ | Real phone; 45 minutes | Interrupt every flow. Calls, notifications, app switching, screen lock, rotation, low-battery warnings | Lost input, lost state, crashes | §9.5 |
| CH-05 | Admin changes during use | STATE | P2 | STAGE | ✋ | Staging; portal access; 60 minutes | Change the official in the portal while they work. Role, permissions, block, new password, client switched off | What the official sees within a minute, and anything still shown that the role no longer allows | §6.5, §7.2 |
| CH-06 | A first-time user | POS | P3 | DEVICE | ✋ | Mock build; someone who has not used the app; 45 minutes | The main tasks without help: log in, look up, scan, report, find a check in History | Where they hesitate, texts they misread, steps they cannot find | §13 |
| CH-07 | Accessibility walk | A11Y | P2 | DEVICE | ✋ | Real phone; TalkBack, font 3×; 45 minutes | Do every main task with TalkBack, then with the largest font, then with one hand | Controls that cannot be reached or are not read | §14 |
| CH-08 | A long shift | PERF | P3 | STAGE | ✋ | Staging; real phone; 60 minutes | A normal hour of work across several renewals | Slowdowns, memory growth, unexpected Login screens | §6.4 |
| CH-09 | Time and dates | I18N | P2 | STAGE | ✋ | Staging; real phone; 45 minutes | Confuse the clock. Other time zones, 12- and 24-hour settings, a wrong date, around midnight Bangladesh time | Wrong times, History date filters that miss checks, wrong expiry warnings | §16 |
