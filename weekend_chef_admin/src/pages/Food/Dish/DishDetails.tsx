import { useCallback, useEffect, useState, useRef } from 'react';
import Breadcrumb from '../../../components/Breadcrumbs/Breadcrumb';
import { baseUrl, baseUrlMedia, userToken } from '../../../constants';
import { Link, useParams } from 'react-router-dom';
import EditDishModal from './modals/EditDishesModal';
import AddIngredientModal from './modals/AddIngredientsModal';
import EditIngredientModal from '../Ingredients/modals/EditIngredientModal';
import AddDishCustomOptionsModal from './modals/AddDishCustomOptionsModal';
import AddDishRelationModal from './modals/AddDishRelationModal';
import MapGL, { Marker } from 'react-map-gl';





const DishDetails = () => {
  const mapRef = useRef(null);

  const [search, setSearch] = useState('');
  const [page, setPage] = useState(1);

  const [activeTab, setActiveTab] = useState(0);
  const { dish_id } = useParams();

  const [loading, setLoading] = useState(false);
  const [dishDetails, setDishDetails] = useState({});
  const [ingredients, setIngredients] = useState([]);
  const [customOptions, setCustomOption] = useState([]);
  const [relatedFoods, setRelatedFoods] = useState([]);
  const [chefs, setChefs] = useState([]);
  const [galleryImages, setGalleryImages] = useState([]);
  const [dishCategories, setDishCategories] = useState([]);

  const [isEditModalOpen, setIsEditModalOpen] = useState(false);
  const [isAddIngredientModalOpen, setIsAddIngredientModalOpen] =
    useState(false);
  const [isEditIngredientModalOpen, setIsEditIngredientModalOpen] =
    useState(false);

  const [isAddCustomOptionModalOpen, setIsAddCustomOptionModalOpen] =
    useState(false);
  const [isAddRelatedFoodModalOpen, setIsAddRelatedFoodModalOpen] =
    useState(false);


    // Sample data: List of chef kitchen locations
    const kitchenLocations = [
      { id: 1, name: 'Chef Kitchen 1', latitude: 8.6, longitude: -3.9 },
      { id: 2, name: 'Chef Kitchen 2', latitude: 8.8, longitude: -4.0 },
      { id: 3, name: 'Chef Kitchen 3', latitude: 8.7, longitude: -3.8 },
    ];

  const item = {
    title: 'Cheese Burger',
    description:
      'A delicious cheeseburger with fresh ingredients and a side of fries.',
    price: 12.99,
    category: 'Main Course',
    image: 'https://via.placeholder.com/500', // Replace with your image link
  };

  const openEditItemModal = () => {
    setIsEditModalOpen(true);
  };

  const closeEditItemModal = () => {
    setIsEditModalOpen(false);
  };

  const openAddIngredientModal = () => {
    setIsAddIngredientModalOpen(true);
  };

  const closeAddIngredientModal = () => {
    setIsAddIngredientModalOpen(false);
  };

  const openEditIngredientModal = () => {
    setIsEditIngredientModalOpen(true);
  };

  const closeEditIngredientModal = () => {
    setIsEditIngredientModalOpen(false);
  };

  const openAddCustomOptionModal = () => {
    setIsAddCustomOptionModalOpen(true);
  };

  const closeAddCustomOptionModal = () => {
    setIsAddCustomOptionModalOpen(false);
  };

  const openAddRelatedFoodModal = () => {
    setIsAddRelatedFoodModalOpen(true);
  };

  const closeAddRelatedFoodModal = () => {
    setIsAddRelatedFoodModalOpen(false);
  };

  const fetchData = useCallback(async () => {
    setLoading(true);
    try {
      const response = await fetch(
        `${baseUrl}api/food/get-dish-details/?dish_id=${encodeURIComponent(
          dish_id,
        )}`,
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
      setDishDetails(data.data.dish_details);
      setIngredients(data.data.ingredients);
      setCustomOption(data.data.custom_options);
      setRelatedFoods(data.data.related_foods);
      setChefs(data.data.chefs);
    } catch (error) {
      console.error('Error fetching data:', error);
    } finally {
      setLoading(false);
    }
  }, [baseUrl, dish_id, userToken]);

  const tabs = [
    {
      label: 'Ingredient',
      content: (
        <Ingredients
          ingredients={ingredients}
          openAddIngredientModal={openAddIngredientModal}
          closeAddIngredientModal={closeAddIngredientModal}
          dish_id={dish_id}
          openEditIngredientModal={openEditIngredientModal}
          isEditIngredientModalOpen={isEditIngredientModalOpen}
          closeEditIngredientModal={closeEditIngredientModal}
          fetchData={fetchData}
        />
      ),
    },
    {
      label: 'Custom Options',
      content: (
        <CustomOptions
          options={customOptions}
          openAddCustomOptionModal={openAddCustomOptionModal}
          closeAddCustomOptionModal={closeAddCustomOptionModal}
        />
      ),
    },
    {
      label: 'Related foods',
      content: (
        <RelatedFoods
          relatedFoods={relatedFoods}
          openAddRelatedFoodModal={openAddRelatedFoodModal}
        />
      ),
    },
    { label: 'Chefs', content: <Chefs chefs={chefs} /> },
    { label: 'Gallery', content: <Gallery galleryImages={galleryImages} /> },
  ];

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
  }, [baseUrl, userToken]);

  useEffect(() => {
    fetchData();
    fetchCategories();
  }, [fetchData, fetchCategories]);

  return (
    <div>
      <Breadcrumb pageName="Dish / Details" />
  
      <div className="grid grid-cols-1 md:grid-cols-3 gap-8 p-6">
  {/* Dish Details */}
  <div className="col-span-1 md:col-span-2 rounded-lg border border-stroke shadow-lg dark:border-strokedark dark:bg-boxdark">
    <div className="flex flex-col md:flex-row gap-8 items-start p-6">
      {/* Item Image */}
      <div className="flex-2 w-full md:w-1/3">
        <img
          src={
            dishDetails.cover_photo
              ? `${baseUrlMedia}${dishDetails.cover_photo}`
              : item.image
          }
          alt={item.title}
          className="w-full h-80 rounded-lg shadow-lg object-cover"
        />
      </div>

      {/* Item Details */}
      <div className="flex-1 space-y-4">
        <div className="flex justify-between items-center">
          <h2 className="text-3xl font-semibold text-gray-800">
            {dishDetails.name}
          </h2>
          {/* Edit Dish Button */}
          <button
            onClick={openEditItemModal}
            className="text-primary h-[30px] font-semibold bg-transparent border border-primary text-sm px-4 rounded-md hover:bg-primary hover:text-white transition"
          >
            Edit Dish
          </button>
        </div>

        <p className="text-gray-600">
          <span className="font-bold">ID: </span>
          {dishDetails.dish_id}
        </p>
        <p className="text-gray-600">{dishDetails.description}</p>
        <div className="flex items-center gap-4">
          <p className="text-xl font-bold text-gray-800">{`Ghc ${dishDetails.base_price}`}</p>
          <div className="text-sm text-white bg-primary inline-block px-4 py-1 rounded-full">
            {dishDetails.category_name}
          </div>
        </div>

        <p className="text-gray-600">{dishDetails.value}</p>
      </div>
    </div>
  </div>

  {/* Map */}
  <div className="col-span-1 rounded-lg border border-stroke shadow-lg dark:border-strokedark dark:bg-boxdark overflow-hidden"> {/* Added overflow-hidden */}
    {/* Ensure the container takes up the full height and width */}
    <div className="w-full h-[400px]"> {/* Set a specific height to prevent overflow */}
      <MapGL
        ref={mapRef}
        mapboxAccessToken="pk.eyJ1IjoiZGVsYWRlbS1waW5nc2hpcCIsImEiOiJjbTVwNGtuYnowcjUzMmlzOHYxcXd5YWkxIn0.nKSC4i5LZk2_QT0xh-WQSg"
        initialViewState={{
          longitude: -3.9,
          latitude: 8.6,
          zoom: 6,
        }}
        style={{ width: '100%', height: '100%' }}
        mapStyle="mapbox://styles/deladem-pingship/cluv4uiay004y01p5b7es8xp0"
      >
        {/* Render a Marker for each kitchen location */}
        {kitchenLocations.map((location) => (
          <Marker
            key={location.id}
            latitude={location.latitude}
            longitude={location.longitude}
          >
            <button
              onClick={() => handleMarkerClick(location)}
              className="bg-blue-500 text-white p-2 rounded-full shadow-md"
              title={`Click to view ${location.name}`}
            >
              <span>🍴</span> {/* You can use an icon here */}
            </button>
          </Marker>
        ))}
      </MapGL>
    </div>
  </div>
</div>


      <EditDishModal
            isOpen={isEditModalOpen}
            onClose={closeEditItemModal}
            fetchData={fetchData}
            dishCategories={dishCategories}
            dishDetails={dishDetails}
            dish_id={dish_id}
          />
  
      {/* AddItemModal to display the Item form */}
      <AddIngredientModal
        isOpen={isAddIngredientModalOpen}
        onClose={closeAddIngredientModal}
        fetchData={fetchData}
        dish_id={dish_id}
      />
  
      <AddDishCustomOptionsModal
        isOpen={isAddCustomOptionModalOpen}
        onClose={closeAddCustomOptionModal}
        fetchData={fetchData}
        dish_id={dish_id}
      />
  
      <AddDishRelationModal
        isOpen={isAddRelatedFoodModalOpen}
        onClose={closeAddRelatedFoodModal}
        fetchData={fetchData}
        dish_id={dish_id}
      />
  
      <div className="w-full mx-auto mt-10">
        {/* Tab buttons */}
        <div className="flex space-x-4 border-b border-gray-100">
          {tabs.map((tab, index) => (
            <button
              key={index}
              className={`py-2 px-4 font-medium ${
                activeTab === index
                  ? 'border-b-2 border-primary text-primary'
                  : 'text-gray-500 hover:text-primary'
              }`}
              onClick={() => setActiveTab(index)}
            >
              {tab.label}
            </button>
          ))}
        </div>
  
        {/* Tab content */}
        <div className="p-4 bg-gray-100 mt-1 rounded-md">
          {tabs[activeTab].content}
        </div>
      </div>
    </div>
  );
  
};

export default DishDetails;

const Ingredients = ({
  ingredients,
  openAddIngredientModal,
  dish_id,
  openEditIngredientModal,
  isEditIngredientModalOpen,
  closeEditIngredientModal,
  closeAddIngredientModal,
  fetchData,
}) => {
  const [selectedOption, setSelectedOption] = useState(null);
  const [selectedIngredientId, setSelectedIngredientId] = useState(null); // State to store the selected ingredient ID

  const handleSelection = (id) => {
    setSelectedOption(id === selectedOption ? null : id); // Toggle selection
  };

  const openEditIngredient = (id) => {
    setSelectedIngredientId(id); // Update the selected ingredient ID
    openEditIngredientModal(id); // Trigger modal with the selected ID
  };

  return (
    <div className="">
      <div className="flex justify-between">
        <h3 className="text-xl font-semibold text-gray-800 mb-4">
          Ingredients
        </h3>
        <button
          className="bg-primary h-7 text-white px-4 text-sm py-1 rounded-xl"
          onClick={openAddIngredientModal}
        >
          Add Ingredient
        </button>
      </div>
      <div className="flex flex-wrap gap-6">
        {ingredients.map((ingredient) => (
          <div
            key={ingredient.ingredient_id}
            onClick={() => handleSelection(ingredient.ingredient_id)}
            className={`relative flex flex-col items-center w-32 bg-white p-4 rounded-lg shadow-md hover:shadow-lg transition duration-300 
            ${
              selectedOption === ingredient.ingredient_id
                ? 'border-4 border-primary'
                : ''
            }`}
          >
            {/* Edit Icon - SVG */}
            <div
              className="absolute top-2 right-2 cursor-pointer text-gray-500 hover:text-primary transition duration-200"
              onClick={(e) => {
                e.stopPropagation(); // Prevent click from propagating to parent div
                openEditIngredient(ingredient.ingredient_id); // Pass ingredient ID to modal
              }}
            >
              <svg
                xmlns="http://www.w3.org/2000/svg"
                className="w-5 h-5"
                fill="none"
                viewBox="0 0 24 24"
                stroke="currentColor"
              >
                <path
                  strokeLinecap="round"
                  strokeLinejoin="round"
                  strokeWidth="2"
                  d="M13.828 3.172a4 4 0 015.656 5.656L6 17.828V20h2.172l9.484-9.484a4 4 0 00-5.656-5.656L10.828 6 3 13.828V20h6.172L18 12.828z"
                />
              </svg>
            </div>

            {/* EditItemModal to display the Item form */}
            <EditIngredientModal
              isOpen={isEditIngredientModalOpen}
              onClose={closeEditIngredientModal}
              fetchData={fetchData}
              ingredient_id={selectedIngredientId} // Pass the selected ID to the modal
              dish_id={dish_id}
            />

            {/* Ingredient Details */}
            <Link
              className="flex flex-col items-center justify-center space-y-2"
              to={'/ingredient-details/' + ingredient.ingredient_id}
            >
              <img
                src={`${baseUrlMedia}${ingredient.photo}`}
                alt={ingredient.name}
                className="w-20 h-20 object-cover rounded-full"
              />
              <div className="text-center">
                <span className="block text-gray-800 font-medium">
                  {ingredient.name}
                </span>
                <span className="block text-gray-800 text-sm">
                  Ghc {ingredient.price}
                </span>
                <span className="block text-gray-800 text-xs">{`${ingredient.quantity} ${ingredient.unit}`}</span>
              </div>
            </Link>
          </div>
        ))}
      </div>
    </div>
  );
};

const CustomOptions = ({
  options,
  openAddCustomOptionModal,
  closeAddCustomOptionModal,
}) => {
  const [selectedOption, setSelectedOption] = useState(null);

  const handleSelection = (id) => {
    setSelectedOption(id === selectedOption ? null : id); // Toggle selection
  };

  return (
    <div className="">
      <div className="flex justify-between">
        <h3 className="text-xl font-semibold text-gray-800 mb-4">
          Custom Options
        </h3>
        <button
          className="bg-primary h-7 text-white px-4 text-sm py-1 rounded-xl"
          onClick={openAddCustomOptionModal}
        >
          Add Custom Option
        </button>
      </div>
      <div className="flex flex-wrap gap-6">
        {options.map((option) => (
          <div
            key={option.custom_option_id}
            onClick={() => handleSelection(option.custom_option_id)}
            className={`flex flex-col items-center w-32 bg-white p-4 rounded-lg shadow-md hover:shadow-lg transition duration-300 
              ${
                selectedOption === option.custom_option_id
                  ? 'border-4 border-primary'
                  : ''
              }`}
          >
            <img
              src={`${baseUrlMedia}${option.photo}`}
              alt={option.name}
              className="w-20 h-20 object-cover rounded-full mb-2"
            />
            <span className="text-center text-gray-800 font-medium">
              {option.name}
            </span>
            <span className="text-center text-gray-800 text-sm">
              Ghc {option.price}
            </span>
            <span className="text-center text-gray-800 text-xs">{`${option.quantity} ${option.unit}`}</span>
          </div>
        ))}
      </div>
    </div>
  );
};

const RelatedFoods = ({ relatedFoods, openAddRelatedFoodModal }) => {
  return (
    <div className="">
      <div className="flex justify-between">
        <h3 className="text-xl font-semibold text-gray-800 mb-4">
          Related Foods
        </h3>
        <button
          className="bg-primary h-7 text-white px-4 text-sm py-1 rounded-xl"
          onClick={openAddRelatedFoodModal}
        >
          Add Related food
        </button>
      </div>
      <div className="grid grid-cols-2 sm:grid-cols-3 lg:grid-cols-4 gap-6">
        {relatedFoods.map((food) => (
          <div
            key={food.dish_id}
            className="bg-white rounded-lg shadow-md overflow-hidden hover:shadow-lg transition duration-300"
          >
            <img
              src={`${baseUrlMedia}${food.cover_photo}`}
              alt={food.name}
              className="w-full h-48 object-cover"
            />
            <div className="p-4">
              <h4 className="text-md font-medium text-gray-800">{food.name}</h4>

              <div className="flex items-center justify-between">
                <p className="text-sm text-gray-500 mt-2">{food.base_price}</p>
                <div className="text-sm text-white bg-primary inline-block px-4 py-1 rounded-full">
                  {food.category_name}
                </div>
              </div>
            </div>
          </div>
        ))}
      </div>
    </div>
  );
};

const Chefs = ({ chefs }) => {
  return (
    <div className="">
      <h3 className="text-lg font-semibold text-gray-800 mb-4">Our Chefs</h3>
      <div className="flex space-x-6">
        {chefs.map((chef, index) => (
          <div key={index} className="flex items-center space-x-4">
            <img
              src={`${baseUrlMedia}${chef.user.photo}`}
              alt={`${chef.user.first_name}`}
              className="w-16 h-16 rounded-full object-cover"
            />
            <div>
              <h4 className="text-md font-semibold text-gray-800">
                {`${chef.user.first_name} ${chef.user.last_name}`}
              </h4>
              <p className="text-sm text-gray-600"></p>
              {`${chef.kitchen_location}`}
            </div>
          </div>
        ))}
      </div>
    </div>
  );
};

const Gallery = ({ galleryImages }) => {
  return (
    <div className="">
      <div className="flex justify-between">
        <h3 className="text-xl font-semibold text-gray-800 mb-4">Gallery</h3>
        <button className="bg-primary h-7 text-white px-4 text-sm py-1 rounded-xl">
          Add image
        </button>
      </div>{' '}
      <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-6">
        {galleryImages.map((image, index) => (
          <div
            key={index}
            className="bg-white shadow-md rounded-lg overflow-hidden"
          >
            <img
              src={`${baseUrlMedia}${image.photo}`}
              alt={`Gallery Image ${index + 1}`}
              className="w-full h-48 object-cover"
            />
          </div>
        ))}
      </div>
    </div>
  );
};
