export function normalizeTag(tag) {
  if (!tag) return { label: "", permalink: "" };

  const prettify = (str) =>
    str
      .replace(/-/g, " ")
      .replace(/\b\w/g, (c) => c.toUpperCase());

  if (typeof tag === "object") {
    return {
      label: prettify(tag.label ?? tag.name ?? ""),
      permalink: tag.permalink ?? "",
    };
  }

  return {
    label: prettify(tag),
    permalink: `/blog/tags/${tag.toLowerCase().replace(/\s+/g, "-")}`,
  };
}
