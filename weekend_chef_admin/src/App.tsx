import { useEffect, useState } from 'react';
import { Route, Routes, useLocation } from 'react-router-dom';

import Loader from './common/Loader';
import PageTitle from './components/PageTitle';

import Dashboard from './pages/Dashboard/Dashboard';

import Alerts from './pages/UiElements/Alerts';
import Buttons from './pages/UiElements/Buttons';
import DefaultLayout from './layout/DefaultLayout';
import AllUsers from './pages/Users/AllUsers';
import UserDetails from './pages/Users/UserDetails';
import AddUser from './pages/Users/AddUser';
import SignUp from './pages/Authentication/SignUp';
import SignIn from './pages/Authentication/SignIn';

import AllDishCategories from './pages/Food/DishCategories/AllDishCategories';
import AllDishes from './pages/Food/Dish/AllDishes';
import ArchivedDishCategories from './pages/Food/DishCategories/ArchivedDishCategories';
import ArchivedDishes from './pages/Food/Dish/ArchivedDish';
import DishDetails from './pages/Food/Dish/DishDetails';
import AllCustomOptions from './pages/Food/CustomOptions/AllCustomOptions';
import ArchivedCustomOptions from './pages/Food/CustomOptions/ArchivedCustomOptions';
import CustomOptionDetails from './pages/Food/CustomOptions/CustomOptionDetails';
import IngredientDetails from './pages/Food/Ingredients/IngredientDetails';
import MapView from './pages/Food/Dish/MapView';

const hiddenOnRoutes = ['/', '/signup', '/signin'];

function App() {
  const [loading, setLoading] = useState<boolean>(true);
  const { pathname } = useLocation();

  useEffect(() => {
    window.scrollTo(0, 0);
  }, [pathname]);

  useEffect(() => {
    setTimeout(() => setLoading(false), 1000);
  }, []);

  return loading ? (
    <Loader />
  ) : (
    <DefaultLayout pathname={pathname} hiddenOnRoutes={hiddenOnRoutes}>
      <Routes>
        <Route
          path="/dashboard"
          element={
            <>
              <PageTitle title="Dashboard |Weekend Chef Admin." />
              <Dashboard />
            </>
          }
        />

        <Route
          index
          element={
            <>
              <PageTitle title="Sign In |Weekend Chef Admin." />
              <SignIn />
            </>
          }
        />

        <Route
          path="/signup"
          element={
            <>
              <PageTitle title="Sign Up |Weekend Chef Admin." />
              <SignUp />
            </>
          }
        />

        <Route
          path="/signin"
          element={
            <>
              <PageTitle title="Sign In |Weekend Chef Admin." />
              <SignIn />
            </>
          }
        />

        <Route
          path="/all-dish-categories"
          element={
            <>
              <PageTitle title="All Dish Categories | Weekend Chef Admin." />
              <AllDishCategories />
            </>
          }
        />

        <Route
          path="/archived-dish-categories"
          element={
            <>
              <PageTitle title="Archived Dish Categories | Weekend Chef Admin." />
              <ArchivedDishCategories />
            </>
          }
        />

        <Route
          path="/all-dishes"
          element={
            <>
              <PageTitle title="All Dishes | Weekend Chef Admin." />
              <AllDishes />
            </>
          }
        />

        <Route
          path="/dish-details/:dish_id"
          element={
            <>
              <PageTitle title="Dish Details | Weekend Chef Admin." />
              <DishDetails />
            </>
          }
        />

        <Route
          path="/archived-dishes"
          element={
            <>
              <PageTitle title="Archived Dish | Weekend Chef Admin." />
              <ArchivedDishes />
            </>
          }
        />

        <Route
          path="/all-custom-options"
          element={
            <>
              <PageTitle title="All Custom Options | Weekend Chef Admin." />
              <AllCustomOptions />
            </>
          }
        />

        <Route
          path="/custom-option-details/:custom_option_id"
          element={
            <>
              <PageTitle title="Custom Option Details | Weekend Chef Admin." />
              <CustomOptionDetails />
            </>
          }
        />

        <Route
          path="/archived-custom-options"
          element={
            <>
              <PageTitle title="Archived Custom Options | Weekend Chef Admin." />
              <ArchivedCustomOptions />
            </>
          }
        />









<Route
          path="/ingredient-details/:ingredient_id"
          element={
            <>
              <PageTitle title="Ingredient Details | Weekend Chef Admin." />
              <IngredientDetails />
            </>
          }
        />


<Route
          path="/map-view/"
          element={
            <>
              <PageTitle title="MapView | Weekend Chef Admin." />
              <MapView />
            </>
          }
        />








        <Route
          path="/all-users"
          element={
            <>
              <PageTitle title="All Users |Weekend Chef Admin." />
              <AllUsers />
            </>
          }
        />

        <Route
          path="/user-details/:user_id"
          element={
            <>
              <PageTitle title="User Details |Weekend Chef Admin." />
              <UserDetails />
            </>
          }
        />

        <Route
          path="/add-user"
          element={
            <>
              <PageTitle title="Add User |Weekend Chef Admin." />
              <AddUser />
            </>
          }
        />

        <Route
          path="/ui/alerts"
          element={
            <>
              <PageTitle title="Alerts |Weekend Chef Admin. " />
              <Alerts />
            </>
          }
        />
        <Route
          path="/ui/buttons"
          element={
            <>
              <PageTitle title="Buttons |Weekend Chef Admin." />
              <Buttons />
            </>
          }
        />
      </Routes>
    </DefaultLayout>
  );
}

export default App;
