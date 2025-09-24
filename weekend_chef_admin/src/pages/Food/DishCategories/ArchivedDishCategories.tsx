import { useCallback, useEffect, useState } from 'react';
import { Link } from 'react-router-dom';
import { baseUrl, baseUrlMedia, userToken } from '../../../constants';
import Pagination from '../../../components/Pagination';
import Alert2 from '../../UiElements/Alert2';
import ArchiveConfirmationModal from '../../../components/ArchiveConfirmationModal';
import Breadcrumb from '../../../components/Breadcrumbs/Breadcrumb';
import UnArchiveConfirmationModal from '../../../components/UnArchiveConfirmationModal';

const ArchivedDishCategories = () => {
  const [search, setSearch] = useState('');
  const [page, setPage] = useState(1);
  const [categories, setCategories] = useState([]);
  const [totalPages, setTotalPages] = useState(1); // Default to 1 to avoid issues
  const [loading, setLoading] = useState(false);

  const [itemToArchive, setItemToArchive] = useState(null);

    // State for confirmation modal
  const [isArchiveModalOpen, setIsArchiveModalOpen] = useState(false);
  const [isAddModalOpen, setIsAddModalOpen] = useState(false);

  // State for alerts
  const [alert, setAlert] = useState({ message: '', type: '' });


  const openAddItemModal = () => {
    setIsAddModalOpen(true);
  };

  const closeAddItemModal = () => {
    setIsAddModalOpen(false);
  };



  const fetchData = useCallback(async () => {
    setLoading(true);
    try {
      const response = await fetch(
        `${baseUrl}api/food/get-all-archived-food-categories/?search=${encodeURIComponent(
          search,
        )}&page=${page}`,
        {
          headers: {
            'Content-Type': 'application/json',
            Authorization: `Token ${userToken}`,
          },
        },
      );

      if (!response.ok) {
        throw new Error('Network response was not ok');
      }

      const data = await response.json();
      setCategories(data.data.food_categories);
      setTotalPages(data.data.pagination.total_pages);
      console.log('Total Pages:', data.data.pagination.total_pages);
    } catch (error) {
      console.error('Error fetching data:', error);
    } finally {
      setLoading(false);
    }
  }, [baseUrl, search, page, userToken]);

  useEffect(() => {
    fetchData();
  }, [fetchData]);



  
  const handleUnArchive = async (itemId) => {
    const data = { id: itemId };

    try {
      const response = await fetch(`${baseUrl}api/food/unarchive-food-category/`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          Authorization: `Token ${userToken}`,
        },
        body: JSON.stringify(data),
      });

      if (!response.ok) {
        throw new Error('Failed to archive the item');
      }

      // Refresh the data after Archive
      await fetchData();
      setAlert({ message: 'Item unarchived successfully', type: 'success' });
    } catch (error) {
      console.error('Error unarchiving item:', error);
      setAlert({
        message: 'An error occurred while unarchiving the item',
        type: 'error',
      });
    } finally {
      setIsArchiveModalOpen(false);
      setItemToArchive(null);
    }
  };




  const openArchiveModal = (itemId) => {
    setItemToArchive(itemId);
    setIsArchiveModalOpen(true);
  };

  const closeArchiveModal = () => {
    setIsArchiveModalOpen(false);
    setItemToArchive(null);
  };

  const closeAlert = () => {
    setAlert({ message: '', type: '' });
  };

  return (


    <div>
        <Breadcrumb pageName="Dish Categories / Archives" />

<div className='grid grid-cols-3 gap-2'>
      
      <div className="col-span-2 rounded-sm border border-stroke  shadow-default dark:border-strokedark dark:bg-boxdark">
        <div className="py-6 px-4 md:px-6 xl:px-7.5">
          <h4 className="text-xl font-semibold text-black dark:text-white">
            Archived Dish Categories
          </h4>
        </div>
  
        <div className="grid grid-cols-5 gap-5 py-6 px-4 md:px-6 xl:px-7.5">
          <input
            type="text"
            placeholder="Search here"
            className="w-full rounded border-[1.5px] border-stroke bg-transparent py-3 px-5 text-black outline-none transition focus:border-primary active:border-primary disabled:cursor-default disabled:bg-whiter dark:border-form-strokedark dark:bg-form-input dark:text-white dark:focus:border-primary"
            value={search}
            onChange={(e) => setSearch(e.target.value)}
          />
  
    


        </div>
  

       
        <div className="grid grid-cols-6 border-t border-stroke py-4.5 px-4 dark:border-strokedark sm:grid-cols-6 md:px-6 2xl:px-7.5">
          <div className="col-span-2 flex items-center">
            <p className="font-medium">Name</p>
          </div>
          <div className="col-span-3 hidden items-center sm:flex mr-4">
            <p className="font-medium">Description</p>
          </div>
     
   
  
          <div className="col-span-1 flex items-center">
            <p className="font-medium">Actions</p>
          </div>
        </div>
  
        {categories
          ? categories.map((category) => (
              <div
                className="grid grid-cols-6 border-t border-stroke py-4.5 px-4 dark:border-strokedark sm:grid-cols-6 md:px-6 2xl:px-7.5 hover:bg-gray"
                key={category.id}
              >
                <div className="col-span-2 flex items-center">
                  <div className="flex flex-col gap-4 sm:flex-row sm:items-center">
                    <div className="flex flex-col gap-4 sm:flex-row sm:items-center">
                      <div className="h-12 w-12 overflow-hidden rounded-md">
                        <img
                          src={`${baseUrlMedia}${category.photo}`}
                          alt="Category"
                          className="h-full w-full object-cover"
                        />
                      </div>
                    </div>
                    <p className="text-sm text-black dark:text-white">
                      {`${category.name}`}
                    </p>
                  </div>
                </div>
  
                <div className="col-span-3 hidden items-center sm:flex mr-4">
                  <p className="text-sm text-black dark:text-white">
                    {category.description}
                  </p>
                </div>
  
  
  
  
                <div className="col-span-1 hidden items-center sm:flex">
                  <p className="text-sm text-black dark:text-white">
                    <div className="flex items-center space-x-3.5">
                      <button className="hover:text-primary">
                        <Link to={'/category-details/' + category.id}>
                          <svg
                            className="fill-current"
                            width="18"
                            height="18"
                            viewBox="0 0 18 18"
                            fill="none"
                            xmlns="http://www.w3.org/2000/svg"
                          >
                            <path
                              d="M8.99981 14.8219C3.43106 14.8219 0.674805 9.50624 0.562305 9.28124C0.47793 9.11249 0.47793 8.88749 0.562305 8.71874C0.674805 8.49374 3.43106 3.20624 8.99981 3.20624C14.5686 3.20624 17.3248 8.49374 17.4373 8.71874C17.5217 8.88749 17.5217 9.11249 17.4373 9.28124C17.3248 9.50624 14.5686 14.8219 8.99981 14.8219ZM1.85605 8.99999C2.4748 10.0406 4.89356 13.5562 8.99981 13.5562C13.1061 13.5562 15.5248 10.0406 16.1436 8.99999C15.5248 7.95936 13.1061 4.44374 8.99981 4.44374C4.89356 4.44374 2.4748 7.95936 1.85605 8.99999Z"
                              fill=""
                            />
                            <path
                              d="M9 11.3906C7.67812 11.3906 6.60938 10.3219 6.60938 9C6.60938 7.67813 7.67812 6.60938 9 6.60938C10.3219 6.60938 11.3906 7.67813 11.3906 9C11.3906 10.3219 10.3219 11.3906 9 11.3906ZM9 7.875C8.38125 7.875 7.875 8.38125 7.875 9C7.875 9.61875 8.38125 10.125 9 10.125C9.61875 10.125 10.125 9.61875 10.125 9C10.125 8.38125 9.61875 7.875 9 7.875Z"
                              fill=""
                            />
                          </svg>
                        </Link>
                      </button>
                      <button 
                         onClick={() => openArchiveModal(category.id)} 
                      
                      className="hover:text-primary">
                        <svg
                          className="fill-current"
                          width="18"
                          height="18"
                          viewBox="0 0 18 18"
                          fill="none"
                          xmlns="http://www.w3.org/2000/svg"
                        >
                          <path
                            d="M16.8754 11.6719C16.5379 11.6719 16.2285 11.9531 16.2285 12.3187V14.8219C16.2285 15.075 16.0316 15.2719 15.7785 15.2719H2.22227C1.96914 15.2719 1.77227 15.075 1.77227 14.8219V12.3187C1.77227 11.9812 1.49102 11.6719 1.12539 11.6719C0.759766 11.6719 0.478516 11.9531 0.478516 12.3187V14.8219C0.478516 15.7781 1.23789 16.5375 2.19414 16.5375H15.7785C16.7348 16.5375 17.4941 15.7781 17.4941 14.8219V12.3187C17.5223 11.9531 17.2129 11.6719 16.8754 11.6719Z"
                            fill=""
                          />
                          <path
                            d="M8.55074 12.3469C8.66324 12.4594 8.83199 12.5156 9.00074 12.5156C9.16949 12.5156 9.31012 12.4594 9.45074 12.3469L13.4726 8.43752C13.7257 8.1844 13.7257 7.79065 13.5007 7.53752C13.2476 7.2844 12.8539 7.2844 12.6007 7.5094L9.64762 10.4063V2.1094C9.64762 1.7719 9.36637 1.46252 9.00074 1.46252C8.66324 1.46252 8.35387 1.74377 8.35387 2.1094V10.4063L5.40074 7.53752C5.14762 7.2844 4.75387 7.31252 4.50074 7.53752C4.24762 7.79065 4.27574 8.1844 4.50074 8.43752L8.55074 12.3469Z"
                            fill=""
                          />
                        </svg>
                      </button>
  
              
                    </div>
                  </p>
                </div>
              </div>
            ))
          : null}
        <Pagination
          pagination={{
            page_number: page,
            total_pages: totalPages,
            next: page < totalPages ? page + 1 : null,
            previous: page > 1 ? page - 1 : null,
          }}
          setPage={setPage}
        />
  
        
        {/* Render the alert */}
        <Alert2 message={alert.message} type={alert.type} onClose={closeAlert} />
     
  
        <UnArchiveConfirmationModal
          isOpen={isArchiveModalOpen}
          itemId={itemToArchive}
          onConfirm={handleUnArchive}
          onCancel={closeArchiveModal}
    
    />
  
  

   </div>
  
  
   <div className="col-span-1 rounded-sm border border-stroke  shadow-default dark:border-strokedark dark:bg-boxdark">
      
  
  
   </div>
      </div>
  

    </div>





  );
};

export default ArchivedDishCategories;
