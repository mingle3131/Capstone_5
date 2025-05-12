// 다크모드 토글 버튼
const toggleBtn = document.getElementById('toggle-theme-btn');

function setInitialTheme() {
  const saved = localStorage.getItem('theme');
  if (saved === 'dark' || (!saved && window.matchMedia('(prefers-color-scheme: dark)').matches)) {
    document.body.classList.add('dark-mode');
    toggleBtn.textContent = '☀️ 라이트모드';
  }
}

setInitialTheme();

toggleBtn.addEventListener('click', () => {
  const isDark = document.body.classList.toggle('dark-mode');
  toggleBtn.textContent = isDark ? '☀️ 라이트모드' : '🌙 다크모드';
  localStorage.setItem('theme', isDark ? 'dark' : 'light');
});

// 연도 입력 4자리 제한
const yearInput = document.getElementById('year-input');
yearInput.addEventListener('input', () => {
  if (yearInput.value.length > 4) {
    yearInput.value = yearInput.value.slice(0, 4);
  }
});

// 네비게이션 서브메뉴 표시
const menuItems = document.querySelectorAll('.menu-item');
menuItems.forEach(item => {
  item.addEventListener('mouseenter', () => {
    const submenu = item.querySelector('.submenu');
    if (submenu) submenu.style.display = 'block';
  });

  item.addEventListener('mouseleave', () => {
    const submenu = item.querySelector('.submenu');
    if (submenu) submenu.style.display = 'none';
  });
});

document.addEventListener('DOMContentLoaded', () => {
  // Fetch and populate auction list when the page loads
  fetchAuctionData();
});

async function fetchAuctionData() {
  try {
    // Make sure the URL is correct relative to where index.html is served
    const response = await fetch('http://127.0.0.1:8000/api/auctions/'); 
    if (!response.ok) {
      throw new Error(`HTTP error! status: ${response.status}`);
    }
    const auctions = await response.json();
    populateAuctionTable(auctions);
  } catch (error) {
    console.error('Error fetching auction data:', error);
    // Optionally display an error message in the table or elsewhere
    const tableSection = document.querySelector('.auction-list');
    if (tableSection) {
        const tableBody = tableSection.querySelector('table tbody');
        if (tableBody) {
            tableBody.innerHTML = '<tr><td colspan="6">데이터를 불러오는 중 오류가 발생했습니다.</td></tr>';
        }
    }
  }
}

function populateAuctionTable(auctions) {
  // Find the section containing the "기일경매목록" table
  const tableSection = document.querySelector('.auction-list'); 
  if (!tableSection) {
    console.error('Could not find the .auction-list section');
    return; 
  }
  // Find the first table's body within that section
  const tableBody = tableSection.querySelector('table tbody'); 
  if (!tableBody) {
    console.error('Could not find the table body within .auction-list');
    return; 
  }

  // Clear existing placeholder rows (like the example row in index.html)
  tableBody.innerHTML = ''; 

  // Check if there's any auction data
  if (!auctions || auctions.length === 0) {
      tableBody.innerHTML = '<tr><td colspan="6">표시할 경매 목록이 없습니다.</td></tr>';
      return;
  }

  // Populate with new data
  auctions.forEach(auction => {
    const row = tableBody.insertRow();

    // 사건번호
    const cellCaseId = row.insertCell();
    cellCaseId.textContent = auction.case_id || '정보 없음'; 

    // 최저입찰가 (Format as Korean Won)
    const cellMinBid = row.insertCell();
    cellMinBid.textContent = auction.min_bid !== null 
        ? parseInt(auction.min_bid).toLocaleString('ko-KR') + '원' 
        : '정보 없음'; 
    cellMinBid.style.textAlign = 'right'; // Align currency to the right

    // 입찰횟수
    const cellFailures = row.insertCell();
    cellFailures.textContent = auction.auction_failures !== null 
        ? `${auction.auction_failures}회` 
        : '정보 없음';
    cellFailures.style.textAlign = 'center'; // Center align count

    // 마감시간
    const cellDeadline = row.insertCell();
    // Assuming deadline is already formatted 'YYYY-MM-DD HH:MM' from backend
    cellDeadline.textContent = auction.deadline || '정보 없음'; 

    // 즐겨찾기 (Placeholder)
    const cellFavorite = row.insertCell();
    cellFavorite.textContent = '♡'; 
    cellFavorite.style.textAlign = 'center';
    cellFavorite.style.cursor = 'pointer'; // Indicate it's clickable
    // TODO: Add functionality to add/remove favorite

    // 입찰하기 버튼
    const cellBid = row.insertCell();
    const bidButton = document.createElement('button');
    bidButton.textContent = '입찰하기';
    bidButton.classList.add('btn-secondary');
    // TODO: Add event listener or link for the bid button
    // Example: bidButton.onclick = () => redirectToBidPage(auction.case_id);
    cellBid.appendChild(bidButton);
    cellBid.style.textAlign = 'center';
  });
}