document.addEventListener("DOMContentLoaded", function () {
    // --- Image Slider Logic ---
    const imagePaths = [
      "../choonsik/choonsik-main.jfif",
      "../choonsik/choonsik-1.jfif",
      "../choonsik/choonsik-2.jfif",
      "../choonsik/choonsik-3.jfif"
    ];

    let currentIndex = 0;

    // 요소 선택
    const mainImage = document.getElementById("mainImage");
    const imageCounter = document.getElementById("image-counter");

    // 이미지와 카운터 업데이트 함수
    function updateImage() {
      // Check if elements exist before trying to access properties
      if (mainImage) {
          mainImage.src = imagePaths[currentIndex];
      }
      if (imageCounter) {
        imageCounter.textContent = `${currentIndex + 1} / ${imagePaths.length}`;
      }
    }

    // 썸네일 클릭 시
    function setMainImage(index) {
      currentIndex = index;
      updateImage();
    }

    // 왼쪽 화살표 클릭 시
    function prevImage() {
      currentIndex = (currentIndex - 1 + imagePaths.length) % imagePaths.length;
      updateImage();
    }

    // 오른쪽 화살표 클릭 시
    function nextImage() {
      currentIndex = (currentIndex + 1) % imagePaths.length;
      updateImage();
    }

    // 페이지 로드 시 초기 이미지 설정 (only if mainImage exists)
    if (mainImage) {
      updateImage();
    }


    // 전역 등록 (onclick 속성에서 호출 가능하게 하기 위해)
    window.setMainImage = setMainImage;
    window.prevImage = prevImage;
    window.nextImage = nextImage;

    // --- Fetch Auction Details ---
    // Only run fetch logic if we are on a page that needs it (e.g., has the item-name element)
    if (document.getElementById('item-name')) {
        const itemId = 1; // CHANGE THIS to the desired item ID or get it dynamically
        const serverUrl = 'http://localhost:8000'; // Use localhost as confirmed working
        fetch(`${serverUrl}/api/item/${itemId}`) // Use absolute URL without trailing slash
            .then(response => {
                if (!response.ok) {
                    // Log the response status text for more details on the error
                    console.error('Fetch response status:', response.status, response.statusText);
                    throw new Error(`HTTP error! status: ${response.status}`);
                }
                return response.json();
            })
            .then(data => {
                console.log("Auction Data:", data); // Log data for debugging

                // --- Populate HTML elements ---
                // Helper function to safely set text content
                const setText = (id, value, defaultValue = 'N/A') => {
                    const element = document.getElementById(id);
                    if (element) {
                        element.textContent = value || defaultValue;
                    } else {
                        console.warn(`Element with ID '${id}' not found.`);
                    }
                };
                 // Helper function to safely set href attribute
                 const setHref = (id, value) => {
                    const element = document.getElementById(id);
                    if (element) {
                        element.href = value || '#'; // Default to '#' if no value
                    } else {
                        console.warn(`Element with ID '${id}' not found.`);
                    }
                };
                // Helper function to safely set placeholder attribute
                const setPlaceholder = (id, value) => {
                    const element = document.getElementById(id);
                    if (element) {
                        element.placeholder = value || '';
                    } else {
                        console.warn(`Element with ID '${id}' not found.`);
                    }
                };

                // Case Details
                setText('case-number', data.case?.case_id);
                setHref('case-link', data.item?.auction_notice_url); // Using auction_notice_url if available
                setText('item-name', data.case?.case_name, '데이터 없음');

                // Item Details
                const primaryListing = data.listings?.[0];
                setText('item-address', primaryListing?.address || data.claims?.[0]?.address, '주소 정보 없음');
                setText('item-area', data.item?.item_purpose, '면적 정보 없음');

                // Formatting currency and numbers
                const valuationAmount = data.item?.valuation_amount;
                const depositAmount = valuationAmount ? valuationAmount * 0.1 : 0; // Calculate 10% deposit

                setText('item-price', valuationAmount ? `${valuationAmount.toLocaleString('ko-KR')}원` : '가격 정보 없음');
                setText('bid-deposit', depositAmount ? `${depositAmount.toLocaleString('ko-KR')}원` : '정보 없음');
                setPlaceholder('bid-price', `최저매각가격 : ${valuationAmount ? valuationAmount.toLocaleString('ko-KR') : '정보 없음'}원`);

                // Other Info
                // setText('failure-count', `${data.item?.auction_failures || 0}회`); // Uncomment if auction_failures is added
                setText('court-date', data.item?.court_date ? new Date(data.item.court_date).toLocaleDateString('ko-KR') : '날짜 정보 없음');

                // TODO: Add countdown logic based on court_date
                // TODO: Update imagePaths based on data if images are dynamic

            })
            .catch(error => {
                console.error('Error fetching auction details:', error);
                setText('item-name', '데이터 로딩 실패'); // Use helper function here too
            });
    } else {
      // If item-name doesn't exist, maybe log that we're not fetching
      console.log("Not on the auction detail page, skipping data fetch.");
    }
});
