function submissionMain() {
  /**
   * @type {HTMLFormElement | null}
   */
  const form = document.getElementById("submission-form");
  const status = document.getElementById("submission-status");
  if (!form || !status) return;

  form.addEventListener('submit', async (e) => {
    e.preventDefault();

    try {
      const response = await fetch(form.action, {
        method: form.method,
        body: new FormData(form),
      });

      if (response.ok) {
        form.reset();
      } else {
        alert(JSON.stringify(await response.json(), null, 2));
      }

      status.innerText = response.ok
        ? "Successfully submitted entry."
        : "Failed to submit entry.";
    } catch (error) {
      alert(error);
      status.innerText = "Failed to submit entry.";
    }
  });
}

submissionMain()
