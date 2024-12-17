const backgroundContainer = document.getElementById("background-container");
const fetchDogButton = document.getElementById("fetch-dog");
const dogImage = document.getElementById("dog-image");

function createBackdrop() {
  const backdropImg = document.createElement("div");
  backdropImg.classList.add("paw");

  // Randomize position and animation properties on X and Y axes
  const startX = Math.random() * window.innerWidth;
  const startY = Math.random() * window.innerHeight;
  const directionX = (Math.random() - 0.5) * 400;
  const directionY = (Math.random() - 0.5) * 400;
  const duration = Math.random() * 10 + 5;

  // Set initial position
  backdropImg.style.left = `${startX}px`;
  backdropImg.style.top = `${startY}px`;

  // Set custom properties for animation
  backdropImg.style.setProperty("--x", `${directionX}px`);
  backdropImg.style.setProperty("--y", `${directionY}px`);
  backdropImg.style.animationDuration = `${duration}s`;

  const backdropImages = [
    "/static/img/dog.png",
    "/static/img/bone.png",
    "/static/img/dog-food.png",
    "/static/img/dog1.png",
    "/static/img/dog2.png",
  ];

  backdropImg.style.backgroundImage = `url(${
    backdropImages[Math.floor(Math.random() * backdropImages.length)]
  })`;
  backdropImg.style.backgroundSize = "cover";
  backgroundContainer.appendChild(backdropImg);

  setTimeout(() => backdropImg.remove(), duration * 1000);
}

setInterval(createBackdrop, 1000);

async function fetchDog() {
  const response = await fetch("/api/dog");
  const data = await response.json();
  dogImage.src = data.image;
}

fetchDog();

fetchDogButton.addEventListener("click", fetchDog);
