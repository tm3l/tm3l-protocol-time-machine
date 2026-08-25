import React from 'react';

export default function App() {
  return (
    <div className="flex flex-col items-center justify-center min-h-screen bg-slate-950 text-slate-100 p-6">
      <header className="text-center">
        <h1 className="text-4xl font-extrabold tracking-tight sm:text-5xl mb-4">
          ⏳ Protocol Time Machine Explorer
        </h1>
        <p className="text-lg text-slate-400 max-w-2xl mx-auto">
          Interactive visual history of how Internet protocols actually evolved — and why.
        </p>
      </header>
    </div>
  );
}
