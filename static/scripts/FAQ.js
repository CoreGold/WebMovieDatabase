document.addEventListener('DOMContentLoaded', function() {
  const faqItems = document.querySelectorAll('.faq-item');
  const closedHeight = 118;
  const openHeight = 329;
  const gap = 93;
  
  function updatePositions() {
    let currentTop = 470;
    
    faqItems.forEach((item, index) => {
      item.style.top = currentTop + 'px';
      
      if (item.classList.contains('active')) {
        currentTop += openHeight + gap;
      } else {
        currentTop += closedHeight + gap;
      }
    });
  }
  
  faqItems.forEach(item => {
    const header = item.querySelector('.faq-header');
    
    header.addEventListener('click', function() {
      const isActive = item.classList.contains('active');
      
      faqItems.forEach(otherItem => {
        if (otherItem !== item) {
          otherItem.classList.remove('active');
        }
      });
      
      if (isActive) {
        item.classList.remove('active');
      } else {
        item.classList.add('active');
      }
      
      updatePositions();
    });
  });
  
  if (faqItems.length > 0) {
    //faqItems[0].classList.add('active');
    updatePositions();
  }
});