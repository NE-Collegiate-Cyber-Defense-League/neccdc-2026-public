(() => {
  const config = window.ChefOpsForms;
  if (!config) {
    return;
  }

  const openButtons = document.querySelectorAll(".js-open-modal");
  const closeButtons = document.querySelectorAll(".js-close-modal");
  const overlays = document.querySelectorAll(".modal");

  const closeAll = () => {
    overlays.forEach((overlay) => overlay.classList.remove("is-active"));
  };

  openButtons.forEach((button) => {
    button.addEventListener("click", (event) => {
      event.preventDefault();
      const target = button.dataset.target;
      if (!target) {
        return;
      }
      const modal = document.querySelector(target);
      if (modal) {
        closeAll();
        modal.classList.add("is-active");
      }
    });
  });

  closeButtons.forEach((button) => {
    button.addEventListener("click", (event) => {
      event.preventDefault();
      closeAll();
    });
  });

  overlays.forEach((overlay) => {
    overlay.addEventListener("click", (event) => {
      if (event.target === overlay) {
        closeAll();
      }
    });
  });

  const handleSubmit = async (form) => {
    const statusEl = form.querySelector(".form-status");
    const formData = new FormData(form);
    formData.append("action", "chefops_submit_request");
    formData.append("nonce", config.nonce);

    if (statusEl) {
      statusEl.textContent = "Submitting...";
    }

    try {
      const response = await fetch(config.ajaxUrl, {
        method: "POST",
        body: new URLSearchParams(formData),
      });
      const payload = await response.json();

      if (!payload.success) {
        throw new Error(payload.data || "Submission failed.");
      }

      form.reset();
      if (statusEl) {
        statusEl.textContent = payload.data;
      }
    } catch (error) {
      if (statusEl) {
        statusEl.textContent = error.message;
      }
    }
  };

  document.querySelectorAll(".js-request-form").forEach((form) => {
    form.addEventListener("submit", (event) => {
      event.preventDefault();
      handleSubmit(form);
    });
  });
})();
