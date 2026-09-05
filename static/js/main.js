function submissionMain() {
  /**
   * @type {HTMLFormElement | null}
   */
  const form = document.getElementById("index-form");
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

function updateMain() {
  /**
   * @type {HTMLFormElement | null}
   */
  const form = document.getElementById("update-form");
  const status = document.getElementById("submission-status");
  if (!form || !status) return;

  form.addEventListener('submit', async (e) => {
    e.preventDefault();

    try {
      const response = await fetch(form.action, {
        method: form.method,
        body: new FormData(form),
      });

      if (!response.ok) {
        alert(JSON.stringify(await response.json(), null, 2));
      }

      status.innerText = response.ok
        ? "Successfully updated entry."
        : "Failed to update entry.";
    } catch (error) {
      alert(error);
      status.innerText = "Failed to update entry.";
    }
  });
}

updateMain()
