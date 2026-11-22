---
name: cards4play
description: Play classic card games (Rook, Hearts, Euchre, Spades, Bridge, Canasta and more) with the user at a real Cards4Play table through the Cards4Play MCP server. Use when the user wants to play cards, start or join a card game, get advice on a hand, or have the agent take its own seat at a table.
license: MIT
when_to_use: |
  - The user wants to play cards, start a card game, or join a table
  - The user asks for help choosing a move in a card game
  - The user wants their agent to take a seat at a real table
  - Do NOT use for gambling, betting, or real-money play; Cards4Play has none
---

# Cards4Play

Cards4Play is a free online card table. You join as your own player with your own hand; the human
keeps their account and plays their own cards. Use the `cards4play_*` MCP tools only.

## Setup (ask before doing this)

The server is remote. It needs an MCP client that supports remote HTTP and OAuth.

- Claude: Settings → Connectors → Add custom connector → `https://cards4play.com/api/mcp`
- Claude Code: `claude mcp add --transport http cards4play https://cards4play.com/api/mcp`
- Cursor: add `{"mcpServers":{"cards4play":{"url":"https://cards4play.com/api/mcp"}}}` to `.cursor/mcp.json`
- VS Code: add `{"servers":{"cards4play":{"type":"http","url":"https://cards4play.com/api/mcp"}}}` to `.vscode/mcp.json`

The human signs in and approves the `mcp:read` and `mcp:play` scopes. Never ask for a password or a
token in chat.

## Start a table

1. Call `cards4play_list_games` if the user has not named a game.
2. Call `cards4play_create_table` with the game (`hearts`, `spades`, `ohhell`, `whist`, `euchre`,
   `rook`, `cribbage`, `bridge`) and an optional `variant`.
3. Tell the user the game id and ask them to accept the invitation in Cards4Play.
4. Do not call `cards4play_accept_table` for the human. That tool is for the agent's own seat only
   if the flow requires it; the human must accept their own invitation.

## Play

Repeat until the game ends:

1. Call `cards4play_get_state` with the gameId.
2. If it is not your turn, call `cards4play_wait_for_turn` with `timeoutSeconds` 25 and repeat.
3. If it is your turn:
   - To play the house expert's move, call `cards4play_autoplay`.
   - To choose yourself, pick an action id from `legalActions` and call
     `cards4play_submit_action` with `gameId`, `actionId`, `expectedVersion`, and a unique
     `idempotencyKey`.
4. If the server returns a stale state error, call `cards4play_get_state` again before acting.

## Advice instead of play

If the user wants to play their own hand, offer `cards4play_get_advice` and describe the recommended
action in plain language. Do not submit actions on the human's behalf unless they ask you to.

## Hard rules

- Never invent a card, a legal move, or a score. Everything comes from the tools.
- Never ask the user to reveal another player's hand. You only ever see your own hand and public
  table history, by design.
- Never submit more than one action for the same turn. Reuse the same `idempotencyKey` when retrying.
- Cards4Play is free and has no wagering. If the user asks for gambling, explain that this server
  does not offer it.
- If authentication fails, stop and ask the user to reconnect the connector. Do not retry in a loop.

## Example prompts

- "Start a Hearts table and tell me the game id."
- "Join me for Rook. I'll accept the invite, then play your turns."
- "Look at my hand and tell me what to play."
