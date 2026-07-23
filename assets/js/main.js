(function () {
  "use strict";

  const config = window.IVC_CONFIG || {};
  const checkoutUrl = config.checkoutUrl || "#";
  const checkoutPending = checkoutUrl === "#";
  const ctaEventMap = {
    header: "cta_header_click",
    hero: "cta_hero_click",
    offer: "cta_offer_click",
    final: "cta_final_click",
    mobile: "cta_offer_click"
  };

  function trackEvent(name, detail) {
    const payload = Object.assign({ event_category: "imersivo_vibe_code" }, detail || {});

    if (typeof window.gtag === "function") {
      window.gtag("event", name, payload);
    }

    if (Array.isArray(window.dataLayer)) {
      window.dataLayer.push(Object.assign({ event: name }, payload));
    }

    window.IVC_LAST_EVENT = { name: name, detail: payload };
  }

  window.trackImersivoEvent = trackEvent;

  function showToast(message) {
    const toast = document.querySelector("[data-toast]");
    if (!toast) return;

    toast.textContent = message;
    toast.hidden = false;
    window.clearTimeout(showToast.timeoutId);
    showToast.timeoutId = window.setTimeout(function () {
      toast.hidden = true;
    }, 4200);
  }

  function scrollToOffer() {
    const offer = document.getElementById("oferta");
    if (!offer) return;
    offer.scrollIntoView({ behavior: "smooth", block: "start" });
  }

  function setupCheckoutButtons() {
    const buttons = document.querySelectorAll(".js-checkout-cta");
    buttons.forEach(function (button) {
      if (!checkoutPending) {
        button.setAttribute("href", checkoutUrl);
        button.setAttribute("target", "_blank");
        button.setAttribute("rel", "noopener noreferrer");
      }

      button.addEventListener("click", function (event) {
        const location = button.dataset.ctaLocation || "unknown";
        trackEvent(ctaEventMap[location] || "cta_click", { cta_location: location });

        if (!checkoutPending) return;

        event.preventDefault();
        scrollToOffer();
        const note = document.querySelector("[data-checkout-note]");
        if (note) note.hidden = false;
        showToast("As inscrições serão liberadas em breve. O checkout do Asaas será conectado aqui.");
      });
    });
  }

  function setupReveal() {
    const elements = document.querySelectorAll(".reveal");
    if (!("IntersectionObserver" in window)) {
      elements.forEach(function (element) {
        element.classList.add("is-visible");
      });
      return;
    }

    const observer = new IntersectionObserver(function (entries) {
      entries.forEach(function (entry) {
        if (!entry.isIntersecting) return;
        entry.target.classList.add("is-visible");
        observer.unobserve(entry.target);
      });
    }, { threshold: 0.12 });

    elements.forEach(function (element) {
      observer.observe(element);
    });
  }

  function renderFaqs() {
    const list = document.querySelector("[data-faq-list]");
    if (!list || !Array.isArray(config.faqs)) return;

    const fragment = document.createDocumentFragment();

    config.faqs.forEach(function (faq, index) {
      const details = document.createElement("details");
      details.className = "faq-item";

      const summary = document.createElement("summary");
      summary.textContent = faq.question;

      const answer = document.createElement("p");
      answer.textContent = faq.answer;

      details.append(summary, answer);
      details.addEventListener("toggle", function () {
        if (details.open) {
          trackEvent("faq_open", {
            faq_question: faq.question,
            faq_index: index + 1
          });
        }
      });

      fragment.append(details);
    });

    list.append(fragment);
  }

  function renderProofs() {
    const grid = document.querySelector("[data-proof-grid]");
    const empty = document.querySelector("[data-proof-empty]");
    const projects = Array.isArray(config.projects) ? config.projects : [];

    if (!grid) return;

    if (!projects.length) {
      grid.hidden = true;
      if (empty) empty.hidden = false;
      return;
    }

    const fragment = document.createDocumentFragment();

    projects.forEach(function (project) {
      const card = document.createElement("article");
      card.className = "proof-card";

      if (project.screenshot || project.photo) {
        const image = document.createElement("img");
        image.src = project.screenshot || project.photo;
        image.alt = project.built ? "Captura do projeto: " + project.built : "Imagem real do projeto construído";
        card.append(image);
      } else {
        const placeholder = document.createElement("div");
        placeholder.className = "proof-placeholder";
        placeholder.setAttribute("aria-hidden", "true");
        card.append(placeholder);
      }

      const body = document.createElement("div");
      body.className = "proof-card-body";

      const title = document.createElement("h3");
      title.textContent = project.participantName || "Participante";
      body.append(title);

      [
        ["Ideia inicial", project.initialProblem],
        ["Construído", project.built],
        ["Estágio", project.stage]
      ].forEach(function (item) {
        if (!item[1]) return;
        const paragraph = document.createElement("p");
        paragraph.innerHTML = "<strong>" + item[0] + ":</strong> " + item[1];
        body.append(paragraph);
      });

      if (project.testimonial) {
        const quote = document.createElement("blockquote");
        quote.textContent = "“" + project.testimonial + "”";
        body.append(quote);
      }

      if (project.url) {
        const link = document.createElement("a");
        link.href = project.url;
        link.target = "_blank";
        link.rel = "noopener noreferrer";
        link.textContent = "Ver projeto";
        body.append(link);
      }

      card.append(body);
      fragment.append(card);
    });

    grid.hidden = false;
    if (empty) empty.hidden = true;
    grid.append(fragment);
  }

  function setupProofTracking() {
    const proofSection = document.querySelector("[data-proof-section]");
    if (!proofSection || !("IntersectionObserver" in window)) return;

    const observer = new IntersectionObserver(function (entries) {
      entries.forEach(function (entry) {
        if (!entry.isIntersecting) return;
        trackEvent("proof_section_view");
        observer.unobserve(entry.target);
      });
    }, { threshold: 0.35 });

    observer.observe(proofSection);
  }

  function setupMobileCta() {
    const sticky = document.querySelector("[data-mobile-cta]");
    const offer = document.getElementById("oferta");
    if (!sticky) return;

    document.body.classList.add("has-sticky-cta");

    if (!offer || !("IntersectionObserver" in window)) return;

    const observer = new IntersectionObserver(function (entries) {
      entries.forEach(function (entry) {
        sticky.classList.toggle("is-hidden", entry.isIntersecting);
      });
    }, { threshold: 0.18 });

    observer.observe(offer);
  }

  function setupHeaderShadow() {
    const header = document.querySelector("[data-header]");
    if (!header) return;

    function update() {
      header.classList.toggle("is-scrolled", window.scrollY > 12);
    }

    update();
    window.addEventListener("scroll", update, { passive: true });
  }

  setupCheckoutButtons();
  setupReveal();
  renderFaqs();
  renderProofs();
  setupProofTracking();
  setupMobileCta();
  setupHeaderShadow();
})();
