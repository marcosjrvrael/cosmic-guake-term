# ADR-0001: Fork Strategy

We fork `cosmic-term` instead of embedding it as a library. The fork adds a "Guake mode" window management layer on top of the existing terminal engine. We maintain the diff as minimal focused commits on top of upstream master, rebasing frequently to track upstream changes.

This is the simplest path because cosmic-term does not expose an embedding API, and extracting the terminal engine would require significant refactoring. The cost is manual rebase effort when upstream changes.
