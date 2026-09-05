function submissionMain() {
  /**
   * @type {HTMLFormElement | null}
   */
  const form = document.getElementById("index-form");
  const status = document.getElementById("submission-status");
  /**
   * @type {HTMLButtonElement | null}
   */
  const button = document.getElementById("submission-button");
  if (!form || !status || !button) return;

  form.addEventListener('submit', async (e) => {
    e.preventDefault();

    button.disabled = true;
    status.innerText = "Submitting...";

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
    } finally {
      button.disabled = false;
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
  /**
   * @type {HTMLButtonElement | null}
   */
  const button = document.getElementById("submission-button");
  if (!form || !status || !button) return;

  form.addEventListener('submit', async (e) => {
    e.preventDefault();

    button.disabled = true;
    status.innerText = "Submitting...";

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
    } finally {
      button.disabled = false;
    }
  });
}

updateMain()
