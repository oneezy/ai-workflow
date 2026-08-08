"use client";

import { useEffect, useMemo, useState } from "react";

type Tool = {
  Name: string;
  Category: string;
  Status: string;
  Version: string;
  Role: string;
  Platform: string;
  URL: string;
  Notes: string;
  Checked: string;
};

type View = "map" | "table";

const categoryOrder = [
  "IDE",
  "Harness",
  "Orchestration",
  "Workflow",
  "Toolchain",
  "Testing",
  "Sandbox",
  "Deployment",
  "Control",
  "Platform",
  "Infrastructure",
  "Utility",
  "Framework",
  "Design",
  "Communication",
  "Protocol",
];

const statusOrder = [
  "🟢 Use",
  "🔵 Selected",
  "🟡 Test",
  "🟣 Research",
  "⚪ Watch",
  "🟠 Hold",
  "🔴 Rejected",
  "⚫ Replaced",
  "🟤 Archived",
];

function parseCsv(input: string): string[][] {
  const rows: string[][] = [];
  let row: string[] = [];
  let value = "";
  let quoted = false;

  for (let index = 0; index < input.length; index += 1) {
    const character = input[index];
    const next = input[index + 1];

    if (character === '"' && quoted && next === '"') {
      value += '"';
      index += 1;
    } else if (character === '"') {
      quoted = !quoted;
    } else if (character === "," && !quoted) {
      row.push(value);
      value = "";
    } else if ((character === "\n" || character === "\r") && !quoted) {
      if (character === "\r" && next === "\n") index += 1;
      row.push(value);
      if (row.some((cell) => cell.length > 0)) rows.push(row);
      row = [];
      value = "";
    } else {
      value += character;
    }
  }

  if (value.length > 0 || row.length > 0) {
    row.push(value);
    rows.push(row);
  }

  return rows;
}

function statusClass(status: string) {
  return `status-${status.replace(/^\S+\s+/, "").toLowerCase()}`;
}

function ToolName({ tool }: { tool: Tool }) {
  const name = <span>{tool.Name}</span>;
  return tool.URL ? (
    <a href={tool.URL} target="_blank" rel="noreferrer">
      {name}
      <span className="external-mark" aria-hidden="true">↗</span>
    </a>
  ) : name;
}

export default function Home() {
  const [tools, setTools] = useState<Tool[]>([]);
  const [query, setQuery] = useState("");
  const [category, setCategory] = useState("All");
  const [status, setStatus] = useState("All");
  const [view, setView] = useState<View>("map");
  const [loadState, setLoadState] = useState<"loading" | "ready" | "error">("loading");

  useEffect(() => {
    fetch("/tools.csv")
      .then((response) => {
        if (!response.ok) throw new Error("Catalog unavailable");
        return response.text();
      })
      .then((text) => {
        const [headers, ...records] = parseCsv(text);
        const parsed = records.map((record) =>
          Object.fromEntries(headers.map((header, index) => [header, record[index] ?? ""])),
        ) as Tool[];
        setTools(parsed);
        setLoadState("ready");
      })
      .catch(() => setLoadState("error"));
  }, []);

  const categories = useMemo(
    () => categoryOrder.filter((item) => tools.some((tool) => tool.Category === item)),
    [tools],
  );

  const statuses = useMemo(
    () => statusOrder.filter((item) => tools.some((tool) => tool.Status === item)),
    [tools],
  );

  const filteredTools = useMemo(() => {
    const normalizedQuery = query.trim().toLowerCase();
    return tools.filter((tool) => {
      const matchesQuery =
        !normalizedQuery ||
        [tool.Name, tool.Category, tool.Status, tool.Role, tool.Platform, tool.Notes]
          .join(" ")
          .toLowerCase()
          .includes(normalizedQuery);
      return (
        matchesQuery &&
        (category === "All" || tool.Category === category) &&
        (status === "All" || tool.Status === status)
      );
    });
  }, [tools, query, category, status]);

  const activeCount = tools.filter((tool) => tool.Status === "🟢 Use").length;
  const checked = tools.map((tool) => tool.Checked).filter(Boolean).sort().at(-1) ?? "—";
  const visibleCategories = categories.filter(
    (item) => category === "All" || item === category,
  );

  const resetFilters = () => {
    setQuery("");
    setCategory("All");
    setStatus("All");
  };

  return (
    <main>
      <header className="hero">
        <div className="hero-grid" aria-hidden="true" />
        <nav className="eyebrow" aria-label="Catalog identity">
          <span className="signal" />
          AI WORKFLOW / LIVE CATALOG
          <span className="edition">2026.08</span>
        </nav>

        <div className="hero-copy">
          <div>
            <p className="kicker">One evolving source of truth</p>
            <h1>AI Workflow<br /><span>Atlas</span></h1>
            <p className="hero-description">
              A living map of editors, agents, harnesses, infrastructure, and the
              choices connecting them. Powered directly by the project&apos;s canonical CSV.
            </p>
          </div>

          <dl className="metrics">
            <div><dt>Tools</dt><dd>{tools.length || "—"}</dd></div>
            <div><dt>Categories</dt><dd>{categories.length || "—"}</dd></div>
            <div><dt>In use</dt><dd>{tools.length ? activeCount : "—"}</dd></div>
            <div><dt>Checked</dt><dd className="metric-date">{checked}</dd></div>
          </dl>
        </div>
      </header>

      <section className="catalog-shell" aria-labelledby="catalog-heading">
        <div className="catalog-heading-row">
          <div>
            <p className="section-index">01 / EXPLORE</p>
            <h2 id="catalog-heading">The stack, organized.</h2>
          </div>
          <p className="results-count" aria-live="polite">
            {filteredTools.length} of {tools.length} tools
          </p>
        </div>

        <div className="controls">
          <label className="search-field">
            <span className="sr-only">Search tools</span>
            <span aria-hidden="true">⌕</span>
            <input
              type="search"
              value={query}
              onChange={(event) => setQuery(event.target.value)}
              placeholder="Search name, role, platform…"
            />
          </label>

          <label>
            <span className="sr-only">Filter by category</span>
            <select value={category} onChange={(event) => setCategory(event.target.value)}>
              <option value="All">All categories</option>
              {categories.map((item) => <option key={item}>{item}</option>)}
            </select>
          </label>

          <label>
            <span className="sr-only">Filter by status</span>
            <select value={status} onChange={(event) => setStatus(event.target.value)}>
              <option value="All">All statuses</option>
              {statuses.map((item) => <option key={item}>{item}</option>)}
            </select>
          </label>

          <div className="view-switcher" aria-label="Catalog view">
            <button className={view === "map" ? "active" : ""} onClick={() => setView("map")}>Map</button>
            <button className={view === "table" ? "active" : ""} onClick={() => setView("table")}>Table</button>
          </div>
        </div>

        <div className="legend" aria-label="Lifecycle status legend">
          {statusOrder.map((item) => (
            <button
              key={item}
              className={`${statusClass(item)} ${status === item ? "selected" : ""}`}
              onClick={() => setStatus(status === item ? "All" : item)}
              aria-pressed={status === item}
            >
              {item}
            </button>
          ))}
        </div>

        {loadState === "loading" && <div className="state-panel">Loading the catalog…</div>}
        {loadState === "error" && <div className="state-panel error">The catalog could not be loaded.</div>}

        {loadState === "ready" && filteredTools.length === 0 && (
          <div className="state-panel">
            <p>No tools match those filters.</p>
            <button onClick={resetFilters}>Clear filters</button>
          </div>
        )}

        {loadState === "ready" && filteredTools.length > 0 && view === "map" && (
          <div className="map-grid">
            {visibleCategories.map((item, categoryIndex) => {
              const categoryTools = filteredTools.filter((tool) => tool.Category === item);
              if (!categoryTools.length) return null;
              return (
                <article className="category-card" key={item}>
                  <header>
                    <span className="category-number">{String(categoryIndex + 1).padStart(2, "0")}</span>
                    <h3>{item}</h3>
                    <span className="category-count">{categoryTools.length}</span>
                  </header>
                  <ul>
                    {categoryTools.map((tool) => (
                      <li key={tool.Name} className={tool.Status === "🟢 Use" ? "in-use" : ""}>
                        <div className="tool-line">
                          <span className={`status-dot ${statusClass(tool.Status)}`} title={tool.Status} />
                          <ToolName tool={tool} />
                          <span className="tool-version">{tool.Version}</span>
                        </div>
                        <p>{tool.Role}</p>
                      </li>
                    ))}
                  </ul>
                </article>
              );
            })}
          </div>
        )}

        {loadState === "ready" && filteredTools.length > 0 && view === "table" && (
          <div className="table-scroll" tabIndex={0} aria-label="Scrollable detailed tool table">
            <table>
              <thead>
                <tr>
                  <th>Name</th><th>Category</th><th>Status</th><th>Role</th>
                  <th>Version</th><th>Platform</th><th>Notes</th><th>Checked</th>
                </tr>
              </thead>
              <tbody>
                {filteredTools.map((tool) => (
                  <tr key={tool.Name} className={tool.Status === "🟢 Use" ? "in-use" : ""}>
                    <td><ToolName tool={tool} /></td>
                    <td>{tool.Category}</td>
                    <td><span className={`status-pill ${statusClass(tool.Status)}`}>{tool.Status}</span></td>
                    <td>{tool.Role}</td>
                    <td className="mono">{tool.Version}</td>
                    <td>{tool.Platform}</td>
                    <td className="notes-cell">{tool.Notes}</td>
                    <td className="mono">{tool.Checked}</td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        )}
      </section>

      <footer>
        <div><span className="signal" /> CANONICAL SOURCE: tools.csv</div>
        <div>ROWS ALIGN VISUALLY ONLY — NO CROSS-COLUMN RELATIONSHIP</div>
      </footer>
    </main>
  );
}
