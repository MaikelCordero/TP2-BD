import { Routes, Route, BrowserRouter } from 'react-router-dom'
import ShowEmpleados from './ShowEmpleados.jsx'
import './App.css'
import 'bootstrap/dist/css/bootstrap.min.css';
import '@fortawesome/fontawesome-free/css/all.min.css';
import 'bootstrap/dist/js/bootstrap.bundle';


function App() {

  return (
    <BrowserRouter>
      <Routes>
        <Route path="/" element={<ShowEmpleados/>} />
      </Routes>
    </BrowserRouter>
  )
}

export default App
