# PAI Skills Collection

Generic, public-facing skills for the PAI (Personal AI Infrastructure) ecosystem. Works with Claude Code, pi, and other tools that support the SKILL.md format.

## Usage

Skills are loaded automatically by Claude Code when relevant, or invoked directly with `/skill-name`.

```bash
# Install all skills to shared PAI layer
./install.sh  # -> ~/.pai/skills/
```

## Inspirations & Credits

Many skills were developed with patterns and ideas from:

- [danielmiessler/PAI](https://github.com/danielmiessler/Personal_AI_Infrastructure) — PAI framework, Algorithm, hooks, memory system
- [badlogic/pi-mono](https://github.com/badlogic/pi-mono) — pi agent, skill format, community skill patterns
- [Anthropic](https://code.claude.com/docs/en/skills) — Claude Code skills documentation, reference skill patterns
- [superpowers (obra)](https://github.com/obra/superpowers) — skill engineering patterns
- [arminronacher/agent-stuff](https://github.com/mitsuhiko/agent-stuff) — agent skill patterns
- [AgentSkills.io](https://agentskills.io) — open skill standard

## License

MIT
