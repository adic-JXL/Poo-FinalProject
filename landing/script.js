const spriteSets = {
  player: [
    "./assets/img/personaje/idle_00.png",
    "./assets/img/personaje/idle_01.png",
    "./assets/img/personaje/idle_02.png",
    "./assets/img/personaje/idle_03.png",
  ],
  glasses: [
    "./assets/img/objetos/gafas_00.png",
    "./assets/img/objetos/gafas_01.png",
    "./assets/img/objetos/gafas_02.png",
  ],
  slime: [
    "./assets/img/enemigos/slime/slime_00.png",
    "./assets/img/enemigos/slime/slime_01.png",
    "./assets/img/enemigos/slime/slime_02.png",
    "./assets/img/enemigos/slime/slime_03.png",
    "./assets/img/enemigos/slime/slime_04.png",
  ],
  wall: [
    "./assets/img/enemigos/muro_verde/muro_verde_00.png",
    "./assets/img/enemigos/muro_verde/muro_verde_01.png",
    "./assets/img/enemigos/muro_verde/muro_verde_02.png",
    "./assets/img/enemigos/muro_verde/muro_verde_03.png",
    "./assets/img/enemigos/muro_verde/muro_verde_04.png",
    "./assets/img/enemigos/muro_verde/muro_verde_05.png",
    "./assets/img/enemigos/muro_verde/muro_verde_06.png",
    "./assets/img/enemigos/muro_verde/muro_verde_07.png",
  ],
};

const animateSprite = (selector, frames, speed = 180) => {
  const element = document.querySelector(selector);
  if (!element || !frames.length) return;

  let index = 0;
  window.setInterval(() => {
    index = (index + 1) % frames.length;
    element.src = frames[index];
  }, speed);
};

animateSprite("#playerSprite", spriteSets.player, 190);
animateSprite("#glassesSprite", spriteSets.glasses, 150);
animateSprite("#slimeSprite", spriteSets.slime, 160);
animateSprite("#wallSprite", spriteSets.wall, 130);

const revealObserver = new IntersectionObserver(
  entries => {
    entries.forEach(entry => {
      if (entry.isIntersecting) {
        entry.target.classList.add("visible");
        revealObserver.unobserve(entry.target);
      }
    });
  },
  { threshold: 0.16 }
);

document.querySelectorAll(".reveal").forEach(element => revealObserver.observe(element));

const countObserver = new IntersectionObserver(
  entries => {
    entries.forEach(entry => {
      if (!entry.isIntersecting) return;

      const element = entry.target;
      const target = Number(element.dataset.count || "0");
      const duration = 900;
      const start = performance.now();

      const tick = now => {
        const progress = Math.min((now - start) / duration, 1);
        const eased = 1 - Math.pow(1 - progress, 3);
        element.textContent = Math.round(target * eased);
        if (progress < 1) requestAnimationFrame(tick);
      };

      requestAnimationFrame(tick);
      countObserver.unobserve(element);
    });
  },
  { threshold: 0.55 }
);

document.querySelectorAll("[data-count]").forEach(element => countObserver.observe(element));

const links = [...document.querySelectorAll(".nav-links a")];
const sections = links
  .map(link => document.querySelector(link.getAttribute("href")))
  .filter(Boolean);

const navObserver = new IntersectionObserver(
  entries => {
    entries.forEach(entry => {
      if (!entry.isIntersecting) return;
      links.forEach(link => {
        link.classList.toggle("active", link.getAttribute("href") === `#${entry.target.id}`);
      });
    });
  },
  { rootMargin: "-45% 0px -50% 0px" }
);

sections.forEach(section => navObserver.observe(section));

const glow = document.querySelector(".cursor-glow");
const hero = document.querySelector(".hero");
const layers = document.querySelectorAll(".bg-layer");

window.addEventListener("pointermove", event => {
  const x = event.clientX;
  const y = event.clientY;

  if (glow) {
    glow.style.left = `${x}px`;
    glow.style.top = `${y}px`;
  }

  if (!hero) return;
  const rect = hero.getBoundingClientRect();
  const relX = (x - rect.left) / Math.max(rect.width, 1) - 0.5;
  const relY = (y - rect.top) / Math.max(rect.height, 1) - 0.5;

  layers.forEach((layer, index) => {
    const depth = (index + 1) * 8;
    layer.style.setProperty("--move-x", `${relX * depth}px`);
    layer.style.setProperty("--move-y", `${relY * depth * 0.5}px`);
  });
});

document.querySelectorAll(".world-card, .feature-card, .code-card, .result-item").forEach(card => {
  card.addEventListener("pointermove", event => {
    const rect = card.getBoundingClientRect();
    const x = ((event.clientX - rect.left) / rect.width - 0.5) * 8;
    const y = ((event.clientY - rect.top) / rect.height - 0.5) * 8;
    card.style.transform = `translate(${x * 0.18}px, ${y * 0.18}px)`;
  });

  card.addEventListener("pointerleave", () => {
    card.style.transform = "";
  });
});
