import { Routes, Route, BrowserRouter } from 'react-router-dom'
import ShowProducts from './ShowProducts.jsx'
import './App.css'
import 'bootstrap/dist/css/bootstrap.min.css';
import '@fortawesome/fontawesome-free/css/all.min.css';
import 'bootstrap/dist/js/bootstrap.bundle';


function App() {

  return (
    <BrowserRouter>
      <Routes>
        <Route path="/" element={<ShowProducts/>} />
      </Routes>
    </BrowserRouter>
  )
}

export default App
