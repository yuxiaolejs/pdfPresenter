const app = require("express")();
const static = require("express").static;
const fs = require("fs")

app.get("/", (req, res) => {
    res.sendFile(__dirname + "/index.html");
})

app.get("/s.json", (req, res) => {
    fs.readdir(__dirname + "/Slides", (err, files) => {
        if (err) {
            res.status(500).send
            return
        }
        files = files.filter(file => file.endsWith(".png"))
        res.json(files)
    })
})

app.use("/s", static(__dirname + "/Slides"));

app.get("/pack", (req, res) => {
    fs.rm(__dirname + "/dist", { recursive: true }, async (err) => {
        await fs.promises.mkdir(__dirname + "/dist")
        let files = await fs.promises.readdir(__dirname + "/Slides")
        files = files.filter(file => file.endsWith(".png"))
        const idx = await fs.promises.readFile(__dirname + "/index.html", { encoding: "utf-8" })
        const ndx = idx.replace("let slideList = []", `let slideList = ${JSON.stringify(files)}`)
        await fs.promises.writeFile(__dirname + "/dist/slide.html", ndx)
        await fs.promises.cp(__dirname + "/Slides", __dirname + "/dist/s", { recursive: true })
        res.send("Done, the dist folder is ready")
    })
})


app.listen(3000, () => { })