// JavaScript for adding random backdrop prints to the background
const backgroundContainer = document.getElementById('background-container');

function createPaw() {
    const paw = document.createElement('div');
    paw.classList.add('paw');
    
    // Randomize position and animation properties on X and Y axes
    const startX = Math.random() * window.innerWidth;
    const startY = Math.random() * window.innerHeight;
    const directionX = (Math.random() - 0.5) * 400; 
    const directionY = (Math.random() - 0.5) * 400; 
    const duration = Math.random() * 10 + 5; 

    // Set initial position
    paw.style.left = `${startX}px`;
    paw.style.top = `${startY}px`;

    // Set custom properties for animation
    paw.style.setProperty('--x', `${directionX}px`);
    paw.style.setProperty('--y', `${directionY}px`);
    paw.style.animationDuration = `${duration}s`;

    // Add a random backdrop image
    const pawImages = ['img/dog.png', 'img/bone.png', 'img/dog-food.png', 'img/dog1.png', 'img/dog2.png'];
    paw.style.backgroundImage = `url(${pawImages[Math.floor(Math.random() * pawImages.length)]})`;
    paw.style.backgroundSize = 'cover';

    backgroundContainer.appendChild(paw);

    // Remove paw after animation
    setTimeout(() => paw.remove(), duration * 1000);
}

// Add random paws at intervals
setInterval(createPaw, 1000);
