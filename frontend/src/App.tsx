import { BrowserRouter, Route, Routes } from 'react-router-dom';
import { QueryClient, QueryClientProvider } from 'react-query';
import 'mapbox-gl/dist/mapbox-gl.css';

import Layout from './components/Layout';
import Search from './pages/Search';
import Departures from './pages/Departures';
import DeparturesDetails from './pages/DepartureDetails';
import NotFound from './pages/NotFound';

const queryClient = new QueryClient();

function App() {
  return (
    <QueryClientProvider client={queryClient}>
      <BrowserRouter>
        <Layout>
          <Routes>
            <Route path="/" element={<Search />} />
            <Route path="/departures" element={<Departures />} />
            <Route path="/departure-details" element={<DeparturesDetails />} />
            <Route path="*" element={<NotFound />} />
          </Routes>
        </Layout>
      </BrowserRouter>
    </QueryClientProvider>
  );
}

export default App;
