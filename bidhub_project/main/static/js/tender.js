document.addEventListener("DOMContentLoaded", function () {
    const imagePaths = [
      "{% static 'img/ex/01.png' %}",
      "{% static 'img/ex/02.png' %}",
      "{% static 'img/ex/03.png' %}",
      "{% static 'img/ex/04.png' %}",
      "{% static 'img/ex/05.jpg' %}"
    ];

    let currentIndex = 0;
    const mainImage = document.getElementById("mainImage");
    const imageCounter = document.getElementById("image-counter");

    function updateImage() {
      mainImage.src = imagePaths[currentIndex];
      imageCounter.textContent = `${currentIndex + 1} / ${imagePaths.length}`;
    }

    function setMainImage(index) {
      currentIndex = index;
      updateImage();
    }

    function prevImage() {
      currentIndex = (currentIndex - 1 + imagePaths.length) % imagePaths.length;
      updateImage();
    }

    function nextImage() {
      currentIndex = (currentIndex + 1) % imagePaths.length;
      updateImage();
    }

    updateImage();

    window.setMainImage = setMainImage;
    window.prevImage = prevImage;
    window.nextImage = nextImage;
  });