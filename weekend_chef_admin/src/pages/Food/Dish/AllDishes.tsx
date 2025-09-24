import { useCallback, useEffect, useState } from 'react';
import { Link } from 'react-router-dom';
import { baseUrl, baseUrlMedia, truncateText, userToken } from '../../../constants';
import Pagination from '../../../components/Pagination';
import Alert2 from '../../UiElements/Alert2';
import ArchiveConfirmationModal from '../../../components/ArchiveConfirmationModal';
import DeleteConfirmationModal from '../../../components/DeleteConfirmationModal';
import Breadcrumb from '../../../components/Breadcrumbs/Breadcrumb';
import AddDishModal from './modals/AddDishesModal';

const AllDishes = () => {
  const [search, setSearch] = useState('');
  const [page, setPage] = useState(1);
  const [dishes, setDishes] = useState([]);
  const [dishCategories, setDishCategories] = useState([]);
  const [totalPages, setTotalPages] = useState(1); // Default to 1 to avoid issues
  const [loading, setLoading] = useState(false);

  const [itemToDelete, setItemToDelete] = useState(null);
  const [itemToArchive, setItemToArchive] = useState(null);

    // State for delete confirmation modal
  const [isModalOpen, setIsModalOpen] = useState(false);
  const [isArchiveModalOpen, setIsArchiveModalOpen] = useState(false);
  const [isAddModalOpen, setIsAddModalOpen] = useState(false);

  // State for alerts
  const [alert, setAlert] = useState({ message: '', type: '' });


    // State to track which categories are checked
    const [checkedCategories, setCheckedCategories] = useState({});
  
    // Handle checkbox state changes
    const handleCheckboxChange = (dishCategory) => {
      setCheckedCategories((prevState) => ({
        ...prevState,
        [dishCategory.id]: !prevState[dishCategory.id],
      }));

    };
  


    const [priceValue, setPriceValue] = useState(50); // Initial value set to 50

  const handleSliderChange = (event) => {
    setPriceValue(event.target.value);
  };


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
        `${baseUrl}api/food/get-all-dishes/?search=${encodeURIComponent(
          search,
        )}&page=${page}&categories=${JSON.stringify(checkedCategories)}&price=${priceValue}`,
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
      setDishes(data.data.dishes);
      setTotalPages(data.data.pagination.total_pages);
      console.log('Total Pages:', data.data.pagination.total_pages);
    } catch (error) {
      console.error('Error fetching data:', error);
    } finally {
      setLoading(false);
    }
  }, [baseUrl, search, page, userToken, checkedCategories, priceValue]);

  
  
  const fetchCategories = useCallback(async () => {
    setLoading(true);
    try {
      const response = await fetch(
        `${baseUrl}api/food/get-all-food-categories/?search=${encodeURIComponent(
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
      setDishCategories(data.data.food_categories);
      //setTotalPages(data.data.pagination.total_pages);
      //console.log('Total Pages:', data.data.pagination.total_pages);
      console.log('Categories:', data.data.food_categories);
    } catch (error) {
      console.error('Error fetching data:', error);
    } finally {
      setLoading(false);
    }
  }, [baseUrl, search, page, userToken, checkedCategories, priceValue]);

  
  
  
  
  
  useEffect(() => {
    fetchData();
    fetchCategories();
    console.log('Checked Categories:', checkedCategories);
  }, [fetchData, fetchCategories, search, page, checkedCategories, priceValue]);

  const handleDelete = async (itemId) => {
    const data = { dish_id: itemId };

    try {
      const response = await fetch(`${baseUrl}api/food/delete-dish/`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          Authorization: `Token ${userToken}`,
        },
        body: JSON.stringify(data),
      });

      if (!response.ok) {
        throw new Error('Failed to delete the item');
      }

      // Refresh the data after deletion
      await fetchData();
      setAlert({ message: 'Item deleted successfully', type: 'success' });
    } catch (error) {
      console.error('Error deleting item:', error);
      setAlert({
        message: 'An error occurred while deleting the item',
        type: 'error',
      });
    } finally {
      setIsModalOpen(false);
      setItemToDelete(null);
    }
  };


  
  const handleArchive = async (itemId) => {
    const data = { dish_id: itemId };

    try {
      const response = await fetch(`${baseUrl}api/food/archive-dish/`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          Authorization: `Token ${userToken}`,
        },
        body: JSON.stringify(data),
      });

      if (!response.ok) {
        throw new Error('Failed to delete the item');
      }

      // Refresh the data after deletion
      await fetchData();
      setAlert({ message: 'Item archived successfully', type: 'success' });
    } catch (error) {
      console.error('Error archiving item:', error);
      setAlert({
        message: 'An error occurred while archiving the item',
        type: 'error',
      });
    } finally {
      setIsArchiveModalOpen(false);
      setItemToArchive(null);
    }
  };



  const openDeleteModal = (itemId) => {
    setItemToDelete(itemId);
    setIsModalOpen(true);
  };

  const closeDeleteModal = () => {
    setIsModalOpen(false);
    setItemToDelete(null);
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
        <Breadcrumb pageName="Dish" />

<div className='grid grid-cols-3 gap-2'>
      
      <div className="col-span-2 rounded-sm border border-stroke  shadow-default dark:border-strokedark dark:bg-boxdark">
        <div className="py-6 px-4 md:px-6 xl:px-7.5">
          <h4 className="text-xl font-semibold text-black dark:text-white">
            All Dishes
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
  
    
            <button 
                      onClick={openAddItemModal}
  
            
            className="flex w-full justify-center rounded bg-primary p-3 font-medium text-gray hover:bg-opacity-90">
              Add dish
            </button>

            <div></div>

               <div></div>
                       <Link to={'/archived-dishes/'}>
 
            <button 
                 
            
            className="flex w-full justify-center rounded p-3 font-medium text-black hover:bg-opacity-90">
              Archived
            </button>
</Link>
        </div>
  
       {/* AddItemModal to display the Item form */}
       <AddDishModal isOpen={isAddModalOpen} onClose={closeAddItemModal} fetchData={fetchData} dishCategories={dishCategories} />
  
       
        <div className="grid grid-cols-6 border-t border-stroke py-4.5 px-4 dark:border-strokedark sm:grid-cols-6 md:px-6 2xl:px-7.5">
    
         
          <div className="col-span-1 flex items-center">
            <p className="font-medium">Name</p>
          </div>
          <div className="col-span-1 hidden items-center mr-2 sm:flex mr-4">
            <p className="font-medium">Category</p>
          </div>
     
          <div className="col-span-1 hidden items-center sm:flex mr-4">
            <p className="font-medium">Description</p>
          </div>
     
          <div className="col-span-1 hidden items-center sm:flex mr-4">
            <p className="font-medium">Base Price</p>
          </div>
     
          <div className="col-span-1 hidden items-center sm:flex mr-4">
            <p className="font-medium">Value</p>
          </div>
     
  
          <div className="col-span-1 flex items-center">
            <p className="font-medium">Actions</p>
          </div>
        </div>
  
        {dishes
          ? dishes.map((dish) => (
              <div
                className="grid grid-cols-6 border-t border-stroke py-4.5 px-4 dark:border-strokedark sm:grid-cols-6 md:px-6 2xl:px-7.5 hover:bg-gray"
                key={dish.dish_id}
              >



                <div className="col-span-1 flex items-center">
                  <div className="flex flex-col gap-4 sm:flex-row sm:items-center">
                    <div className="flex flex-col gap-4 sm:flex-row sm:items-center">
                      <div className="h-12 w-12 overflow-hidden rounded-md">
                        <img
                          src={`${baseUrlMedia}${dish.cover_photo}`}
                          alt="dish"
                          className="h-full w-full object-cover"
                        />
                      </div>
                    </div>
                    <p className="text-sm text-black dark:text-white">
                      {`${dish.name}`}
                    </p>
                  </div>
                </div>
  
                <div className="col-span-1 hidden items-center mr-2 sm:flex mr-4">
                  <p className="text-sm text-black dark:text-white">
                    {dish.category_name}
                  </p>
                </div>
  
  
                <div className="col-span-1 hidden items-center sm:flex mr-4">
                  <p className="text-sm text-black dark:text-white">
                    {truncateText(dish.description, 20)}
                  </p>
                </div>
  

                <div className="col-span-1 hidden items-center sm:flex mr-4">
                  <p className="text-sm text-black dark:text-white">
                    {dish.base_price}
                  </p>
                </div>


                <div className="col-span-1 hidden items-center sm:flex mr-4">
                  <p className="text-sm text-black dark:text-white">
                    {dish.value}
                  </p>
                </div>
  
  
  
                <div className="col-span-1 hidden items-center sm:flex">
                  <p className="text-sm text-black dark:text-white">
                    <div className="flex items-center space-x-3.5">
                      <button className="hover:text-primary">
                        <Link to={'/dish-details/' + dish.dish_id}>
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
                         onClick={() => openArchiveModal(dish.dish_id)} 
                      
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
  
                      <button
                        className="hover:text-primary"
                        onClick={() => openDeleteModal(dish.dish_id)} // Pass the ID of the item to be deleted
                      >
                        <svg
                          className="fill-current"
                          width="18"
                          height="18"
                          viewBox="0 0 18 18"
                          fill="none"
                          xmlns="http://www.w3.org/2000/svg"
                        >
                          <path
                            d="M13.7535 2.47502H11.5879V1.9969C11.5879 1.15315 10.9129 0.478149 10.0691 0.478149H7.90352C7.05977 0.478149 6.38477 1.15315 6.38477 1.9969V2.47502H4.21914C3.40352 2.47502 2.72852 3.15002 2.72852 3.96565V4.8094C2.72852 5.42815 3.09414 5.9344 3.62852 6.1594L4.07852 15.4688C4.13477 16.6219 5.09102 17.5219 6.24414 17.5219H11.7004C12.8535 17.5219 13.8098 16.6219 13.866 15.4688L14.3441 6.13127C14.8785 5.90627 15.2441 5.3719 15.2441 4.78127V3.93752C15.2441 3.15002 14.5691 2.47502 13.7535 2.47502ZM7.67852 1.9969C7.67852 1.85627 7.79102 1.74377 7.93164 1.74377H10.0973C10.2379 1.74377 10.3504 1.85627 10.3504 1.9969V2.47502H7.70664V1.9969H7.67852ZM4.02227 3.96565C4.02227 3.85315 4.10664 3.74065 4.24727 3.74065H13.7535C13.866 3.74065 13.9785 3.82502 13.9785 3.96565V4.8094C13.9785 4.9219 13.8941 5.0344 13.7535 5.0344H4.24727C4.13477 5.0344 4.02227 4.95002 4.02227 4.8094V3.96565ZM11.7285 16.2563H6.27227C5.79414 16.2563 5.40039 15.8906 5.37227 15.3844L4.95039 6.2719H13.0785L12.6566 15.3844C12.6004 15.8625 12.2066 16.2563 11.7285 16.2563Z"
                            fill=""
                          />
                          <path
                            d="M9.00039 9.11255C8.66289 9.11255 8.35352 9.3938 8.35352 9.75942V13.3313C8.35352 13.6688 8.63477 13.9782 9.00039 13.9782C9.33789 13.9782 9.64727 13.6969 9.64727 13.3313V9.75942C9.64727 9.3938 9.33789 9.11255 9.00039 9.11255Z"
                            fill=""
                          />
                          <path
                            d="M11.2502 9.67504C10.8846 9.64692 10.6033 9.90004 10.5752 10.2657L10.4064 12.7407C10.3783 13.0782 10.6314 13.3875 10.9971 13.4157C11.0252 13.4157 11.0252 13.4157 11.0533 13.4157C11.3908 13.4157 11.6721 13.1625 11.6721 12.825L11.8408 10.35C11.8408 9.98442 11.5877 9.70317 11.2502 9.67504Z"
                            fill=""
                          />
                          <path
                            d="M6.72245 9.67504C6.38495 9.70317 6.1037 10.0125 6.13182 10.35L6.3287 12.825C6.35683 13.1625 6.63808 13.4157 6.94745 13.4157C6.97558 13.4157 6.97558 13.4157 7.0037 13.4157C7.3412 13.3875 7.62245 13.0782 7.59433 12.7407L7.39745 10.2657C7.39745 9.90004 7.08808 9.64692 6.72245 9.67504Z"
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
     
  
        <ArchiveConfirmationModal
          isOpen={isArchiveModalOpen}
          itemId={itemToArchive}
          onConfirm={handleArchive}
          onCancel={closeArchiveModal}
    
    />
  
  
        <DeleteConfirmationModal
          isOpen={isModalOpen}
          itemId={itemToDelete}
          onConfirm={handleDelete}
          onCancel={closeDeleteModal}
        />
   </div>
  

  <div>

  <h1 className="font-semibold textlg mb-3">Filter</h1>


  <div className="col-span-1 rounded-sm border border-stroke shadow-default dark:border-strokedark dark:bg-boxdark">
      <div className="py-6 px-4 md:px-6 xl:px-7.5 border-b border-stroke dark:border-strokedark">
        <h1 className="font-semibold text-lg">Categories</h1>
      </div>

      <div className="flex flex-col gap-5 p-6">
      <div className="space-y-3">
        {loading ? (
          <div>Loading...</div>
        ) : (
          dishCategories.map((dishCategory) => (
            <div key={dishCategory.id} className="flex items-center">
              <label
                htmlFor={dishCategory.id}
                className="flex cursor-pointer select-none items-center space-x-1"
              >
                <div className="relative">
                  <input
                    type="checkbox"
                    id={dishCategory.id}
                    className="sr-only"
                    checked={checkedCategories[dishCategory.id] || false}
                    onChange={() => handleCheckboxChange(dishCategory)}
                  />
                  <div
                    className={`mr-4 flex h-4 w-4 items-center justify-center rounded border-2 transition-all duration-300 ease-in-out ${
                      checkedCategories[dishCategory.id]
                        ? 'bg-primary border-primary'
                        : 'bg-gray-200 border-gray-400'
                    } hover:border-primary`}
                  >
                    {checkedCategories[dishCategory.id] && (
                      <span className="h-2 w-2 rounded bg-white" />
                    )}
                  </div>
                </div>
                <span className="text-gray-700 dark:text-white text-lg">
                  {dishCategory.name}
                </span>
              </label>
            </div>
          ))
        )}
      </div>
    </div>
    </div>


   <div className="col-span-1 rounded-sm border border-stroke  shadow-default dark:border-strokedark dark:bg-boxdark">
      <div className="py-6 px-4 md:px-6 xl:px-7.5 border-b border-stroke dark:border-strokedark">
        <h1 className="font-semibold textlg">Price</h1>
        </div>

        <div className="flex flex-col items-center space-y-4 p-6">
      <label className=" font-medium" htmlFor="rangeSlider">
        Price: {priceValue}
      </label>
      <input
        type="range"
        id="rangeSlider"
        min="0"
        max="100"
        value={priceValue}
        onChange={handleSliderChange}
        className="w-full h-2 bg-gray-300 rounded-lg appearance-none cursor-pointer focus:outline-none focus:ring-2 focus:ring-primary"
      />
      <div className="w-full bg-gray-200 rounded-full h-1.5">
        <div
          className="bg-primary h-1.5 rounded-full"
          style={{ width: `${priceValue}%` }}
        ></div>
      </div>
    </div>
  
   </div>
    



  </div>
  



   
      </div>
  

    </div>





  );
};

export default AllDishes;
