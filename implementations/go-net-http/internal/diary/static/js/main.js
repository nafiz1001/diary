// Optional enhancement (specs/04-design/ui-ux.md). The form works without it.
(() => {
  const form = document.getElementById("index-form");
  const status = document.getElementById("submission-status");
  const button = document.getElementById("submission-button");
  const field = document.getElementById("submission");
  if (!form || !status || !button || !field) return;

  const show = (message, role, reason) => {
    status.textContent = message;
    status.setAttribute("role", role);
    if (reason) status.setAttribute("data-reason", reason);
    else status.removeAttribute("data-reason");
  };
  const messages = {
    empty_text: "Write some text before you submit.",
    store_unavailable: "The entry was not saved. Try again.",
  };

  form.addEventListener("submit", async (event) => {
    event.preventDefault();
    if (button.disabled) return;
    button.disabled = true;
    show("Submitting...", "status");
    try {
      const response = await fetch(form.action, {
        method: "POST",
        headers: { Accept: "application/json" },
        body: new URLSearchParams(new FormData(form)),
      });
      if (response.status === 201) {
        field.value = "";
        show("Entry saved.", "status");
      } else {
        const body = await response.json().catch(() => ({}));
        const reason = body.error in messages ? body.error : "store_unavailable";
        show(messages[reason], "alert", reason);
        field.focus();
      }
    } catch {
      show(messages.store_unavailable, "alert", "store_unavailable");
      field.focus();
    } finally {
      button.disabled = false;
    }
  });
})();
