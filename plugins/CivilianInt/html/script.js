function safeText(value, fallback = "N/A") {
    if (value === undefined || value === null || value === "") {
        return fallback;
    }

    return String(value);
}

function setText(id, value) {
    const el = document.getElementById(id);
    if (el) {
        el.innerText = value;
    }
}

window.addEventListener("message", function(event) {
    const data = event.data || {};

    if (data.action === "show") {
        const container = document.getElementById("license-container");
        if (!container) return;

        const firstName = safeText(data.fn, "");
        const lastName = safeText(data.ln, "");
        const fullName = `${firstName} ${lastName}`.trim() || "NO CIVILIAN";

        container.style.display = "block";

        setText("dl-fullname", fullName.toUpperCase());
        setText("dl-state", safeText(data.state));
        setText("license_number", safeText(data.license_number));
        setText("dob", safeText(data.dob));
        setText("exp", safeText(data.exp));
        setText("address", safeText(data.address).toUpperCase());
        setText("dl-class", safeText(data.class, "D").toUpperCase());
        setText("dl-sex", safeText(data.sex, "N/A").toUpperCase());

        if (data.id) {
            setText("id", safeText(data.id));
        } else {
            setText("id", "");
        }
    }

    if (data.action === "hide") {
        const container = document.getElementById("license-container");
        if (container) {
            container.style.display = "none";
        }
    }
});