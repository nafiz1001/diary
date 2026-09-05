function submissionMain() {
  /**
   * @type {HTMLFormElement | null}
   */
  const submissionForm = document.getElementById("submission-form")
  if (submissionForm) {
    /**
     * @type {HTMLDivElement | null}
     */
    const submissionStatus = document.getElementById("submission-status")
    if (!submissionStatus) {
      alert("Failed to find submission-status element.")
      return
    }

    /**
     * @type {number | undefined}
     */
    let timeout = undefined

    submissionForm.addEventListener('submit', async (e) => {
      // 1. Stop the browser from navigating/redirecting
      e.preventDefault();

      // 2. Extract form data
      const formData = new FormData(submissionForm);

      try {
        // 3. Send the request asynchronously
        const response = await fetch(submissionForm.action, {
          method: submissionForm.method,
          body: formData, // Standard form data (multipart/form-data)
        })

        if (timeout) {
          clearTimeout(timeout)
          timeout = undefined
        }
        timeout = setTimeout(() => {
          submissionStatus.innerText = ""
          timeout = undefined
        }, 3000)

        if (response.ok) {
          submissionStatus.innerText = "Successfully submitted entry."
        } else {
          submissionStatus.innerText = "Failed to submit entry."
          alert(JSON.stringify(await response.json(), undefined, 2))
        }
      } catch (error) {
        alert(error)
      }
    })

    return
  }
}

submissionMain()
