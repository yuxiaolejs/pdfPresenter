const fs = require("fs");

async function pack(task_name, source) {
  await fs.promises.rm(__dirname + `/dist/${task_name}`, {
    recursive: true,
    force: true,
  });
  await fs.promises.mkdir(__dirname + `/dist/${task_name}`);
  let files = await fs.promises.readdir(__dirname + `/${source}`);
  files = files.filter((file) => file.endsWith(".png"));
  const idx = await fs.promises.readFile(__dirname + "/index.html", {
    encoding: "utf-8",
  });
  const ndx = idx.replace(
    "let slideList = []",
    `let slideList = ${JSON.stringify(files)}`
  );
  await fs.promises.writeFile(__dirname + `/dist/${task_name}/slide.html`, ndx);
  await fs.promises.cp(
    __dirname + `/${source}`,
    __dirname + `/dist/${task_name}/s`,
    { recursive: true }
  );
}

if (process.argv.length !== 4) {
  console.log("Usage: node convert.js [task_name] [source_folder]");
  process.exit(1);
}

const [task_name, source] = process.argv.slice(2);
pack(task_name, source).then(() => {
  console.log(`Packing for task "${task_name}" from source "${source}" done.`);
});
