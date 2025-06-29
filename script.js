document.addEventListener('DOMContentLoaded', () => {
    const tocList = document.getElementById('table-of-contents');
    const dynamicContentArea = document.getElementById('dynamic-content-area');

    const pages = [
        { id: 'features', title: '🚀 Features', file: 'features.html' },
        { id: 'how-to-use', title: '🧩 How to Use', file: 'how-to-use.html' },
        {
            id: 'node-reference',
            title: '🧑‍💻 Node Reference',
            file: 'node-reference.html',
            children: [
                { id: 'pointtrigger', title: 'PointTrigger', file: 'pointtrigger.html' },
                { id: 'pointhover', title: 'PointHover', file: 'pointhover.html' },
                { id: 'pointhold', title: 'PointHold', file: 'pointhold.html' },
                { id: 'pointdrag', title: 'PointDrag', file: 'pointdrag.html' },
                { id: 'pointsnap', title: 'PointSnap', file: 'pointsnap.html' },
                { id: 'pointradial', title: 'PointRadial', file: 'pointradial.html' },
                { id: 'pointsliderh-pointsliderv', title: 'PointSliderH / PointSliderV', file: 'pointsliderh-pointsliderv.html' }
            ]
        },
        { id: 'example-use-cases', title: '🧪 Example Use Cases', file: 'example-use-cases.html' },
        { id: 'notes', title: '⚠️ Notes', file: 'notes.html' },
        { id: 'license', title: '📜 License', file: 'license.html' }
    ];

    // Create a flat map for quick lookup of all pages (including children)
    let allPagesMap = new Map();
    function populateAllPagesMap(pageArray) {
        pageArray.forEach(page => {
            allPagesMap.set(page.id, page);
            if (page.children) {
                populateAllPagesMap(page.children);
            }
        });
    }
    populateAllPagesMap(pages);

    // Helper to remove leading emojis for display in TOC (only applies to top-level)
    function cleanTocText(text) {
        return text.replace(/^(🚀|🧩|🧑‍💻|🧪|⚠️|📜)\s+/, '').trim();
    }

    /**
     * Loads content for the specified page into the dynamic content area.
     * @param {string} pageId - The ID of the page to load (e.g., 'features', 'license').
     */
    async function loadContent(pageId) {
        const page = allPagesMap.get(pageId);
        if (!page) {
            console.error(`Page with ID "${pageId}" not found. Falling back to features.`);
            loadContent('features'); // Fallback to a default page if the requested one doesn't exist
            return;
        }

        try {
            const response = await fetch(`./content/${page.file}`);
            if (!response.ok) {
                throw new Error(`HTTP error! status: ${response.status}`);
            }
            const htmlContent = await response.text();
            dynamicContentArea.innerHTML = htmlContent;

            // Update active state in TOC sidebar
            // Remove active from all links
            document.querySelectorAll('.sidebar ul li a').forEach(link => {
                link.classList.remove('active');
            });

            // Find and add active class to the current page link
            const activeLink = document.querySelector(`.sidebar ul li a[href="#${pageId}"]`);
            if (activeLink) {
                activeLink.classList.add('active');

                // Ensure all parent li.has-children and their direct ul.nested-list are expanded.
                // This ensures the path to the active link is open without closing other branches
                // that the user might have manually expanded.
                let currentParentLi = activeLink.closest('li.has-children');
                while (currentParentLi) {
                    currentParentLi.classList.add('expanded');
                    const subUl = currentParentLi.querySelector('ul.nested-list');
                    if (subUl) {
                        subUl.classList.add('expanded');
                    }
                    // Traverse up the DOM to find the next parent li.has-children
                    // This handles nested lists correctly.
                    currentParentLi = currentParentLi.parentElement.closest('li.has-children');
                }
            }

            // Update URL hash without causing a full page reload
            history.pushState({ page: pageId }, '', `#${pageId}`);

            // Scroll to the top of the dynamic content area
            dynamicContentArea.scrollTo({ top: 0, behavior: 'smooth' });

        } catch (error) {
            console.error(`Failed to load content for page "${pageId}":`, error);
            dynamicContentArea.innerHTML = `<p style="color: #e06c75;">Error loading content for "${cleanTocText(page.title)}". Please try again later.</p>`;
        }
    }

    /**
     * Generates the Table of Contents in the sidebar based on the defined pages.
     * Handles nested structures for sub-pages.
     */
    function generateTableOfContents() {
        tocList.innerHTML = ''; // Clear existing TOC

        const createTOCItem = (page, parentUl) => {
            const listItem = document.createElement('li');
            const link = document.createElement('a');
            link.href = `#${page.id}`;
            link.textContent = cleanTocText(page.title); // Use clean title for display
            listItem.appendChild(link);
            parentUl.appendChild(listItem);

            // If the page has children, create a nested ul and add toggle functionality
            if (page.children && page.children.length > 0) {
                listItem.classList.add('has-children');

                const subUl = document.createElement('ul');
                subUl.classList.add('nested-list'); // Add a class to identify nested lists
                listItem.appendChild(subUl);

                // Add click listener to the link to toggle the sub-list visibility AND load content
                link.addEventListener('click', (e) => {
                    // Prevent default hash change, as loadContent will handle history.pushState
                    e.preventDefault(); 
                    
                    // Toggle expanded state of the parent list item and the sub-list
                    // This visually opens/closes the dropdown.
                    listItem.classList.toggle('expanded');
                    subUl.classList.toggle('expanded');

                    // Load content for the clicked page
                    loadContent(page.id); 
                });

                page.children.forEach(childPage => createTOCItem(childPage, subUl));
            } else {
                 // For leaf nodes (no children), simply load content
                link.addEventListener('click', (e) => {
                    e.preventDefault();
                    loadContent(page.id);
                });
            }
        };

        pages.forEach(page => createTOCItem(page, tocList));
    }

    // Handle browser back/forward buttons (popstate event)
    window.addEventListener('popstate', (event) => {
        const pageId = event.state && event.state.page ? event.state.page : 'features';
        loadContent(pageId);
    });

    // Initial setup when the page loads:
    generateTableOfContents(); // First, populate the sidebar TOC

    // Determine which page to load initially (from URL hash or default to 'features')
    const initialPageId = window.location.hash ? window.location.hash.substring(1) : 'features';
    loadContent(initialPageId); // Load the determined initial page content
});