// JavaScript for adding random backdrop prints to the background
const backgroundContainer = document.getElementById("background-container");

function createPaw() {
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

  // Add a random backdrop image
  // Update the backdropImages array with correct paths
  const backdropImages = [
    "/client/static/img/dog.png",
    "/client/static/img/bone.png",
    "/client/static/img/dog-food.png",
    "/client/static/img/dog1.png",
    "/client/static/img/dog2.png",
  ];

  backdropImg.style.backgroundImage = `url(${
    backdropImages[Math.floor(Math.random() * backdropImages.length)]
  })`;
  backdropImg.style.backgroundSize = "cover";
  backgroundContainer.appendChild(backdropImg);

  // Remove paw after animation
  setTimeout(() => backdropImg.remove(), duration * 1000);
}
// Add random paws at intervals
setInterval(createPaw, 1000);
